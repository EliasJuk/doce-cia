import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String databaseName = 'doce_cia.db';
  static const int databaseVersion = 2;

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<String> get databasePath async {
    final databasesDirectory = await getDatabasesPath();

    return path.join(
      databasesDirectory,
      databaseName,
    );
  }

  Future<Database> _openDatabase() async {
    return openDatabase(
      await databasePath,
      version: databaseVersion,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createTables,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _upgradeDatabase(
    Database database,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createRecipeStepsTable(database);
    }

    if (oldVersion < 3) {
      await _createSalesTable(database);
    }
  }

  Future<void> _createTables(
    Database database,
    int version,
  ) async {
    await database.transaction((transaction) async {
      await transaction.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await transaction.execute('''
        CREATE TABLE ingredients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          purchase_price REAL NOT NULL,
          purchase_quantity REAL NOT NULL,
          purchase_unit TEXT NOT NULL,
          base_quantity REAL NOT NULL,
          base_unit TEXT NOT NULL,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await transaction.execute('''
        CREATE TABLE recipes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER,
          name TEXT NOT NULL,
          yield_quantity REAL NOT NULL DEFAULT 1,
          yield_unit TEXT NOT NULL DEFAULT 'unidade',
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,

          FOREIGN KEY (category_id)
            REFERENCES categories(id)
            ON DELETE SET NULL
        )
      ''');

      await transaction.execute('''
        CREATE TABLE recipe_ingredients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recipe_id INTEGER NOT NULL,
          ingredient_id INTEGER NOT NULL,
          quantity REAL NOT NULL,
          unit TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,

          FOREIGN KEY (recipe_id)
            REFERENCES recipes(id)
            ON DELETE CASCADE,

          FOREIGN KEY (ingredient_id)
            REFERENCES ingredients(id)
            ON DELETE RESTRICT
        )
      ''');

      await _createRecipeStepsTable(transaction);
      await _createSalesTable(transaction);
      await _insertInitialCategories(transaction);
    });
  }

  Future<void> _createRecipeStepsTable(
    DatabaseExecutor database,
  ) async {
    await database.execute('''
      CREATE TABLE recipe_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER NOT NULL,
        step_number INTEGER NOT NULL,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,

        FOREIGN KEY (recipe_id)
          REFERENCES recipes(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createSalesTable(
    DatabaseExecutor database,
  ) async {
    await database.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        recipe_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        unit_cost REAL NOT NULL,
        sale_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,

        FOREIGN KEY (recipe_id)
          REFERENCES recipes(id)
          ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _insertInitialCategories(
    Transaction transaction,
  ) async {
    final now = DateTime.now().toIso8601String();

    await transaction.insert(
      'categories',
      {
        'name': 'Cookies',
        'icon': '🍪',
        'created_at': now,
        'updated_at': now,
      },
    );

    await transaction.insert(
      'categories',
      {
        'name': 'Tortas',
        'icon': '🥧',
        'created_at': now,
        'updated_at': now,
      },
    );
  }

  Future<void> close() async {
    final database = _database;

    _database = null;

    await database?.close();
  }
}