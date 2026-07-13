import '../../core/database/app_database.dart';
import '../../models/results/sales_by_recipe.dart';
import '../../models/results/sales_period_totals.dart';
import '../../models/sales/sale.dart';

class SaleRepository {
  SaleRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Sale>> findPageByPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required int limit,
    required int offset,
  }) async {
    final database = await _database.database;

    final rows = await database.query(
      'sales',
      where: 'sale_date >= ? AND sale_date < ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'sale_date DESC, id DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map(Sale.fromMap).toList();
  }

  Future<int> countByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final database = await _database.database;

    final rows = await database.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM sales
      WHERE sale_date >= ?
        AND sale_date < ?
      ''',
      [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    return _readInt(rows.first['total']);
  }

  Future<SalesPeriodTotals> calculateTotalsByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final database = await _database.database;

    final rows = await database.rawQuery(
      '''
      SELECT
        COALESCE(SUM(quantity * unit_price), 0) AS gross_revenue,
        COALESCE(SUM(quantity * unit_cost), 0) AS production_costs,
        COALESCE(
          SUM(
            (quantity * unit_price) -
            (quantity * unit_cost)
          ),
          0
        ) AS profit,
        COUNT(*) AS sales_count
      FROM sales
      WHERE sale_date >= ?
        AND sale_date < ?
      ''',
      [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    final row = rows.first;

    return SalesPeriodTotals(
      grossRevenue: _readDouble(row['gross_revenue']),
      productionCosts: _readDouble(row['production_costs']),
      profit: _readDouble(row['profit']),
      salesCount: _readInt(row['sales_count']),
    );
  }

  Future<List<SalesByRecipe>> findSalesByRecipeByPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final database = await _database.database;

    final rows = await database.rawQuery(
      '''
      SELECT
        recipe_name,
        COALESCE(SUM(quantity), 0) AS total_quantity
      FROM sales
      WHERE sale_date >= ?
        AND sale_date < ?
      GROUP BY recipe_name
      ORDER BY total_quantity DESC, recipe_name ASC
      ''',
      [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
    );

    return rows.map((row) {
      return SalesByRecipe(
        recipeName: row['recipe_name'] as String,
        quantity: _readDouble(row['total_quantity']),
      );
    }).toList();
  }

  Future<List<int>> findAvailableYears() async {
    final database = await _database.database;

    final rows = await database.rawQuery(
      '''
      SELECT DISTINCT
        CAST(strftime('%Y', sale_date) AS INTEGER) AS year
      FROM sales
      ORDER BY year DESC
      ''',
    );

    final years = rows
        .map((row) => _readInt(row['year']))
        .where((year) => year > 0)
        .toSet();

    years.add(DateTime.now().year);

    final result = years.toList()
      ..sort((a, b) => b.compareTo(a));

    return result;
  }

  Future<Sale?> findById(int id) async {
    final database = await _database.database;

    final rows = await database.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return Sale.fromMap(rows.first);
  }

  Future<int> insert(Sale sale) async {
    final database = await _database.database;

    return database.insert(
      'sales',
      sale.toMap(includeId: false),
    );
  }

  Future<void> update(Sale sale) async {
    if (sale.id == null) {
      throw ArgumentError(
        'A venda precisa de um ID para ser atualizada.',
      );
    }

    final database = await _database.database;

    final affectedRows = await database.update(
      'sales',
      sale.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [sale.id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'A venda informada não foi encontrada.',
      );
    }
  }

  Future<void> delete(int id) async {
    final database = await _database.database;

    final affectedRows = await database.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'A venda informada não foi encontrada.',
      );
    }
  }

  Future<double> calculateRecipeUnitCost(
    int recipeId,
  ) async {
    final database = await _database.database;

    final recipeRows = await database.query(
      'recipes',
      columns: ['yield_quantity'],
      where: 'id = ?',
      whereArgs: [recipeId],
      limit: 1,
    );

    if (recipeRows.isEmpty) return 0;

    final yieldQuantity = _readDouble(
      recipeRows.first['yield_quantity'],
    );

    if (yieldQuantity <= 0) return 0;

    final rows = await database.rawQuery(
      '''
      SELECT
        ri.quantity,
        ri.unit,
        i.purchase_price,
        i.base_quantity,
        i.base_unit
      FROM recipe_ingredients ri
      INNER JOIN ingredients i
        ON i.id = ri.ingredient_id
      WHERE ri.recipe_id = ?
      ''',
      [recipeId],
    );

    double recipeCost = 0;

    for (final row in rows) {
      final quantity = _readDouble(row['quantity']);
      final unit = row['unit'] as String;
      final purchasePrice = _readDouble(row['purchase_price']);
      final baseQuantity = _readDouble(row['base_quantity']);
      final baseUnit = row['base_unit'] as String;

      if (baseQuantity <= 0) continue;

      final converted = _convertToBaseUnit(
        quantity: quantity,
        unit: unit,
        baseUnit: baseUnit,
      );

      if (converted == null) continue;

      recipeCost += converted * (purchasePrice / baseQuantity);
    }

    return recipeCost / yieldQuantity;
  }

  double? _convertToBaseUnit({
    required double quantity,
    required String unit,
    required String baseUnit,
  }) {
    if (unit == baseUnit) return quantity;
    if (unit == 'kg' && baseUnit == 'g') return quantity * 1000;
    if (unit == 'g' && baseUnit == 'kg') return quantity / 1000;
    if (unit == 'L' && baseUnit == 'ml') return quantity * 1000;
    if (unit == 'ml' && baseUnit == 'L') return quantity / 1000;
    return null;
  }

  int _readInt(Object? value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _readDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
