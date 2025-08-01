import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:spendly/models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'spendly.db');
    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE spend_plans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount REAL,
        date INTEGER
      )
      '''
    );
    await db.execute(
      '''
      CREATE TABLE history_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        amount REAL,
        date INTEGER,
        type TEXT
      )
      '''
    );
    await db.execute(
      '''
      CREATE TABLE app_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baseTotalAmount REAL,
        addSpendPlanToggle INTEGER
      )
      '''
    );
    await db.execute(
      '''
      CREATE TABLE upcoming_incomes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT
      )
      '''
    );
    await db.execute(
      '''
      CREATE TABLE income_tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        incomeSourceId INTEGER,
        title TEXT,
        amount REAL,
        FOREIGN KEY (incomeSourceId) REFERENCES upcoming_incomes(id)
      )
      '''
    );
  }

  // SpendPlan operations
  Future<int> insertSpendPlan(SpendPlan plan) async {
    Database db = await database;
    return await db.insert('spend_plans', plan.toMap());
  }

  Future<List<SpendPlan>> getSpendPlans() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('spend_plans');
    return List.generate(maps.length, (i) {
      return SpendPlan(
        id: maps[i]['id'],
        title: maps[i]['title'],
        amount: maps[i]['amount'],
        date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date']),
      );
    });
  }

  Future<int> updateSpendPlan(SpendPlan plan) async {
    Database db = await database;
    return await db.update(
      'spend_plans',
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<int> deleteSpendPlan(int id) async {
    Database db = await database;
    return await db.delete(
      'spend_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // HistoryItem operations
  Future<int> insertHistoryItem(HistoryItem item) async {
    Database db = await database;
    return await db.insert('history_items', item.toMap());
  }

  Future<List<HistoryItem>> getHistoryItems() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('history_items', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return HistoryItem(
        id: maps[i]['id'],
        description: maps[i]['description'],
        amount: maps[i]['amount'],
        date: DateTime.fromMillisecondsSinceEpoch(maps[i]['date']),
        type: maps[i]['type'],
      );
    });
  }

  // AppData operations
  Future<int> insertAppData(double baseTotalAmount, bool addSpendPlanToggle) async {
    Database db = await database;
    return await db.insert('app_data', {
      'id': 1, // Always use ID 1 for the single app_data row
      'baseTotalAmount': baseTotalAmount,
      'addSpendPlanToggle': addSpendPlanToggle ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getAppData() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('app_data', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete('spend_plans');
    await db.delete('history_items');
    await db.delete('app_data');
    await db.delete('upcoming_incomes');
    await db.delete('income_tasks');
  }

  // UpcomingIncome operations
  Future<int> insertUpcomingIncome(UpcomingIncome income) async {
    Database db = await database;
    return await db.insert('upcoming_incomes', income.toMap());
  }

  Future<List<UpcomingIncome>> getUpcomingIncomes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('upcoming_incomes');
    return List.generate(maps.length, (i) {
      return UpcomingIncome(
        id: maps[i]['id'],
        title: maps[i]['title'],
      );
    });
  }

  Future<int> deleteUpcomingIncome(int id) async {
    Database db = await database;
    return await db.delete(
      'upcoming_incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // IncomeTask operations
  Future<int> insertIncomeTask(IncomeTask task) async {
    Database db = await database;
    return await db.insert('income_tasks', task.toMap());
  }

  Future<List<IncomeTask>> getIncomeTasks(int incomeSourceId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'income_tasks',
      where: 'incomeSourceId = ?',
      whereArgs: [incomeSourceId],
    );
    return List.generate(maps.length, (i) {
      return IncomeTask(
        id: maps[i]['id'],
        incomeSourceId: maps[i]['incomeSourceId'],
        title: maps[i]['title'],
        amount: maps[i]['amount'],
      );
    });
  }

  Future<int> deleteIncomeTasks(int incomeSourceId) async {
    Database db = await database;
    return await db.delete(
      'income_tasks',
      where: 'incomeSourceId = ?',
      whereArgs: [incomeSourceId],
    );
  }

  Future<int> updateIncomeTask(IncomeTask task) async {
    Database db = await database;
    return await db.update(
      'income_tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
