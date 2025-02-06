import 'package:expe_traking/utils/AppValues.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../main/parent/model/expenses_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        expId TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        amount REAL,
        employeeID TEXT,
        expensesStatus TEXT,
        receiptUrl TEXT,
        timeStamp TEXT,
        authorMail TEXT,
        updaterMail TEXT,
        category TEXT
      )
    ''');
  }

  Future<void> insertExpense(ExpensesModel expense) async {
    final db = await instance.database;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<void> insertExpensesList(List<ExpensesModel> expensesList) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var expense in expensesList) {
      batch.insert(
        'expenses',
        expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }
  Future<void> clearExpenses() async {
    final db = await instance.database;
    await db.delete('expenses');
  }
  Future<Map<ExpenseCategoryEnum, double>> getCategoryWiseTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
    ExpensesStatusEnum? expensesStatusFilter,
    ExpenseCategoryEnum? expenseCategoryEnum,
    String? employeeEmailFilter,
  }) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClauses.add("timeStamp >= ?");
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add("timeStamp <= ?");
      whereArgs.add(endDate.toIso8601String());
    }

    if (expensesStatusFilter != null) {
      whereClauses.add("expensesStatus = ?");
      whereArgs.add(expensesStatusFilter.name);
    }

    if (expenseCategoryEnum != null) {
      whereClauses.add("category = ?");
      whereArgs.add(expenseCategoryEnum.name);
    }

    if (employeeEmailFilter != null) {
      whereClauses.add("authorMail = ?");
      whereArgs.add(employeeEmailFilter);
    }

    String whereString =
    whereClauses.isNotEmpty ? whereClauses.join(" AND ") : "";

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: whereString.isNotEmpty ? whereString : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    // Initialize a map to hold the total expenses for each category
    Map<ExpenseCategoryEnum, double> categoryTotals = {};

    for (var map in maps) {
      ExpensesModel expense = ExpensesModel.fromMap(map['expId'], map);
      ExpenseCategoryEnum category = expense.category;

      // If the category is already in the map, add to the total
      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + expense.amount;
      } else {
        // Otherwise, initialize the total for this category
        categoryTotals[category] = expense.amount;
      }
    }

    return categoryTotals;
  }
  Future<List<ExpensesModel>> getFilteredExpenses({
    DateTime? startDate,
    DateTime? endDate,
    ExpensesStatusEnum? expensesStatusFilter,
    ExpenseCategoryEnum? expenseCategoryEnum,
    String? employeeEmailFilter,
    int page = 0, // Pagination (0-based index)
  }) async {
    final db = await instance.database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClauses.add("timeStamp >= ?");
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add("timeStamp <= ?");
      whereArgs.add(endDate.toIso8601String());
    }

    if (expensesStatusFilter != null) {
      whereClauses.add("expensesStatus = ?");
      whereArgs.add(expensesStatusFilter.name);
    }

    if (expenseCategoryEnum != null) {
      whereClauses.add("category = ?");
      whereArgs.add(expenseCategoryEnum.name);
    }

    if (employeeEmailFilter != null) {
      whereClauses.add("authorMail = ?");
      whereArgs.add(employeeEmailFilter);
    }

    String whereString =
        whereClauses.isNotEmpty ? whereClauses.join(" AND ") : "";

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: whereString.isNotEmpty ? whereString : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      limit: AppValues.paginationLimit, // Pagination limit (10 items per page)
      offset: page * AppValues.paginationLimit, // Offset for pagination
    );

    return List.generate(maps.length, (i) {
      return ExpensesModel.fromMap(maps[i]['expId'], maps[i]);
    });
  }

  Future<void> deleteExpense(String expId) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'expId = ?', whereArgs: [expId]);
  }

  Future<void> updateExpense(ExpensesModel expense) async {
    final db = await instance.database;
    await db.update('expenses', expense.toMap(),
        where: 'expId = ?', whereArgs: [expense.expId]);
  }
}
