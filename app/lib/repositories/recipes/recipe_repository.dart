import '../../core/database/app_database.dart';
import '../../models/recipes/recipe.dart';

class RecipeRepository {
  RecipeRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Mantido porque outras telas, como o formulário de venda,
  /// precisam carregar todas as receitas no seletor.
  Future<List<Recipe>> findAll() async {
    final database = await _database.database;

    final rows = await database.query(
      'recipes',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(Recipe.fromMap).toList();
  }

  /// Mantido para compatibilidade com outras partes do app.
  Future<List<Recipe>> findByCategory(
    int categoryId,
  ) async {
    final database = await _database.database;

    final rows = await database.query(
      'recipes',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(Recipe.fromMap).toList();
  }

  Future<List<Recipe>> findPageByCategory({
    required int categoryId,
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
      'recipes',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'name COLLATE NOCASE ASC',
      limit: limit,
      offset: offset,
    );

    return rows.map(Recipe.fromMap).toList();
  }

  Future<Recipe?> findById(int id) async {
    final database = await _database.database;

    final rows = await database.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Recipe.fromMap(rows.first);
  }

  Future<int> insert(
    Recipe recipe,
  ) async {
    final database = await _database.database;

    return database.insert(
      'recipes',
      recipe.toMap(includeId: false),
    );
  }

  Future<void> update(
    Recipe recipe,
  ) async {
    if (recipe.id == null) {
      throw ArgumentError(
        'A receita precisa de um ID para ser atualizada.',
      );
    }

    final database = await _database.database;

    final affectedRows = await database.update(
      'recipes',
      recipe.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'A receita informada não foi encontrada.',
      );
    }
  }

  Future<void> delete(int id) async {
    final database = await _database.database;

    final affectedRows = await database.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'A receita informada não foi encontrada.',
      );
    }
  }

  Future<int> countByCategory(
    int categoryId,
  ) async {
    final database = await _database.database;

    final result = await database.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM recipes
      WHERE category_id = ?
      ''',
      [categoryId],
    );

    final value = result.first['total'];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}