import '../core/database/app_database.dart';
import '../models/ingredient/ingredient.dart';

class IngredientRepository {
  IngredientRepository({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  /// Mantido porque o formulário de receita precisa carregar
  /// todos os ingredientes disponíveis no seletor.
  Future<List<Ingredient>> findAll() async {
    final database = await _database.database;

    final rows = await database.query(
      'ingredients',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return rows.map(Ingredient.fromMap).toList();
  }

  Future<List<Ingredient>> findPage({
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
      'ingredients',
      orderBy: 'name COLLATE NOCASE ASC',
      limit: limit,
      offset: offset,
    );

    return rows.map(Ingredient.fromMap).toList();
  }

  Future<int> countAll() async {
    final database = await _database.database;

    final rows = await database.rawQuery(
      '''
      SELECT COUNT(*) AS total
      FROM ingredients
      ''',
    );

    final value = rows.first['total'];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<int> insert(
    Ingredient ingredient,
  ) async {
    final database = await _database.database;

    return database.insert(
      'ingredients',
      ingredient.toMap(includeId: false),
    );
  }

  Future<void> update(
    Ingredient ingredient,
  ) async {
    if (ingredient.id == null) {
      throw ArgumentError(
        'Ingrediente sem ID.',
      );
    }

    final database = await _database.database;

    final affectedRows = await database.update(
      'ingredients',
      ingredient.toMap(includeId: false),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'O ingrediente informado não foi encontrado.',
      );
    }
  }

  Future<void> delete(int id) async {
    final database = await _database.database;

    final affectedRows = await database.delete(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (affectedRows == 0) {
      throw StateError(
        'O ingrediente informado não foi encontrado.',
      );
    }
  }
}