import '../../core/database/app_database.dart';
import '../../models/sales/sale.dart';

class SaleRepository {
  SaleRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Sale>> findAll() async {
    final database = await _database.database;

    final rows = await database.query(
      'sales',
      orderBy: 'sale_date DESC, id DESC',
    );

    return rows.map(Sale.fromMap).toList();
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

    await database.update(
      'sales',
      sale.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [sale.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await _database.database;

    await database.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
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

    if (recipeRows.isEmpty) {
      return 0;
    }

    final yieldQuantity =
        (recipeRows.first['yield_quantity'] as num).toDouble();

    if (yieldQuantity <= 0) {
      return 0;
    }

    final result = await database.rawQuery(
      '''
      SELECT
        ri.quantity,
        ri.unit,
        i.purchase_price,
        i.base_quantity
      FROM recipe_ingredients ri
      INNER JOIN ingredients i
        ON i.id = ri.ingredient_id
      WHERE ri.recipe_id = ?
      ''',
      [recipeId],
    );

    double recipeCost = 0;

    for (final row in result) {
      final quantity = (row['quantity'] as num).toDouble();
      final unit = row['unit'] as String;
      final purchasePrice =
          (row['purchase_price'] as num).toDouble();
      final baseQuantity =
          (row['base_quantity'] as num).toDouble();

      if (baseQuantity <= 0) {
        continue;
      }

      final quantityInBaseUnit = switch (unit) {
        'kg' => quantity * 1000,
        'L' => quantity * 1000,
        _ => quantity,
      };

      final baseUnitCost = purchasePrice / baseQuantity;

      recipeCost += quantityInBaseUnit * baseUnitCost;
    }

    return recipeCost / yieldQuantity;
  }
}