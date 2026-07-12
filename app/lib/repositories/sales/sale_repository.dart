import '../../core/database/app_database.dart';
import '../../models/sales/sale.dart';

class SaleRepository {
  SaleRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Sale>> findPage({
    required int limit,
    required int offset,
  }) async {
    if (limit <= 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'O limite deve ser maior que zero.',
      );
    }

    if (offset < 0) {
      throw ArgumentError.value(
        offset,
        'offset',
        'O deslocamento não pode ser negativo.',
      );
    }

    final database = await _database.database;

    final rows = await database.query(
      'sales',
      orderBy: 'sale_date DESC, id DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map(Sale.fromMap).toList();
  }

  Future<SalesTotals> calculateTotals() async {
    final database = await _database.database;

    final rows = await database.rawQuery('''
      SELECT
        COALESCE(
          SUM(quantity * unit_price),
          0
        ) AS total_sales,

        COALESCE(
          SUM(
            (quantity * unit_price) -
            (quantity * unit_cost)
          ),
          0
        ) AS total_profit
      FROM sales
    ''');

    final row = rows.first;

    return SalesTotals(
      totalSales: _readDouble(row['total_sales']),
      totalProfit: _readDouble(row['total_profit']),
    );
  }

  Future<Sale?> findById(int id) async {
    final database = await _database.database;

    final rows = await database.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

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
      columns: [
        'yield_quantity',
      ],
      where: 'id = ?',
      whereArgs: [recipeId],
      limit: 1,
    );

    if (recipeRows.isEmpty) {
      return 0;
    }

    final yieldQuantity = _readDouble(
      recipeRows.first['yield_quantity'],
    );

    if (yieldQuantity <= 0) {
      return 0;
    }

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
      final quantity = _readDouble(
        row['quantity'],
      );

      final unit = row['unit'] as String;

      final purchasePrice = _readDouble(
        row['purchase_price'],
      );

      final baseQuantity = _readDouble(
        row['base_quantity'],
      );

      final baseUnit = row['base_unit'] as String;

      if (baseQuantity <= 0) {
        continue;
      }

      final quantityInBaseUnit = _convertToBaseUnit(
        quantity: quantity,
        unit: unit,
        baseUnit: baseUnit,
      );

      if (quantityInBaseUnit == null) {
        continue;
      }

      final baseUnitCost =
          purchasePrice / baseQuantity;

      recipeCost +=
          quantityInBaseUnit * baseUnitCost;
    }

    return recipeCost / yieldQuantity;
  }

  double? _convertToBaseUnit({
    required double quantity,
    required String unit,
    required String baseUnit,
  }) {
    if (unit == baseUnit) {
      return quantity;
    }

    if (unit == 'kg' && baseUnit == 'g') {
      return quantity * 1000;
    }

    if (unit == 'g' && baseUnit == 'kg') {
      return quantity / 1000;
    }

    if (unit == 'L' && baseUnit == 'ml') {
      return quantity * 1000;
    }

    if (unit == 'ml' && baseUnit == 'L') {
      return quantity / 1000;
    }

    return null;
  }

  double _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

class SalesTotals {
  const SalesTotals({
    required this.totalSales,
    required this.totalProfit,
  });

  final double totalSales;
  final double totalProfit;
}