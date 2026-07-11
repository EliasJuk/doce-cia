import '../../core/database/app_database.dart';
import '../../models/categories/recipe_category.dart';

class CategoryRepository {
  CategoryRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<RecipeCategory>> findAll() async {
    final database = await _database.database;

    final rows = await database.query(
      'categories',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(RecipeCategory.fromMap).toList();
  }

  Future<RecipeCategory?> findById(int id) async {
    final database = await _database.database;

    final rows = await database.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return RecipeCategory.fromMap(rows.first);
  }

  Future<int> insert(RecipeCategory category) async {
    final database = await _database.database;

    return database.insert(
      'categories',
      category.toMap(includeId: false),
    );
  }

  Future<void> update(RecipeCategory category) async {
    if (category.id == null) {
      throw ArgumentError(
        'A categoria precisa de um ID para ser atualizada.',
      );
    }

    final database = await _database.database;

    await database.update(
      'categories',
      category.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await _database.database;

    await database.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}