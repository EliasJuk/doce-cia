import '../../core/database/app_database.dart';
import '../../models/recipes/recipe_ingredient.dart';

class RecipeIngredientRepository {
  RecipeIngredientRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<List<RecipeIngredient>> findByRecipe(
    int recipeId,
  ) async {
    final database = await _database.database;

    final rows = await database.query(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'id ASC',
    );

    return rows.map(RecipeIngredient.fromMap).toList();
  }

  Future<int> insert(
    RecipeIngredient recipeIngredient,
  ) async {
    final database = await _database.database;

    return database.insert(
      'recipe_ingredients',
      recipeIngredient.toMap(includeId: false),
    );
  }

  Future<void> update(
    RecipeIngredient recipeIngredient,
  ) async {
    if (recipeIngredient.id == null) {
      throw ArgumentError(
        'O ingrediente da receita precisa de um ID.',
      );
    }

    final database = await _database.database;

    await database.update(
      'recipe_ingredients',
      recipeIngredient.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [recipeIngredient.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await _database.database;

    await database.delete(
      'recipe_ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteByRecipe(int recipeId) async {
    final database = await _database.database;

    await database.delete(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
  }

  Future<void> replaceByRecipe(
    int recipeId,
    List<RecipeIngredient> ingredients,
  ) async {
    final database = await _database.database;

    await database.transaction((transaction) async {
      await transaction.delete(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipeId],
      );

      for (final item in ingredients) {
        await transaction.insert(
          'recipe_ingredients',
          {
            'recipe_id': recipeId,
            'ingredient_id': item.ingredientId,
            'quantity': item.quantity,
            'unit': item.unit,
            'created_at': item.createdAt.toIso8601String(),
            'updated_at': item.updatedAt.toIso8601String(),
          },
        );
      }
    });
  }
}