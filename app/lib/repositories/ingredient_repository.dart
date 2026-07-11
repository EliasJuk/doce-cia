import '../core/database/app_database.dart';
import '../models/ingredient/ingredient.dart';

class IngredientRepository {
  IngredientRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<Ingredient>> findAll() async {
    final db = await _database.database;
    final rows = await db.query(
      'ingredients',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(Ingredient.fromMap).toList();
  }

  Future<int> insert(Ingredient ingredient) async {
    final db = await _database.database;
    return db.insert(
      'ingredients',
      ingredient.toMap(includeId: false),
    );
  }

  Future<void> update(Ingredient ingredient) async {
    if (ingredient.id == null) {
      throw ArgumentError('Ingrediente sem ID.');
    }

    final db = await _database.database;
    await db.update(
      'ingredients',
      ingredient.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _database.database;
    await db.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
