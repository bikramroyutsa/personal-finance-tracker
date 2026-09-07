import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../models/transaction_record.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS transactions');
        await db.execute('DROP TABLE IF EXISTS subcategories');
        await db.execute('DROP TABLE IF EXISTS categories');
        await _createDb(db, newVersion);
      }
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code TEXT NOT NULL,
        color_hex TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE subcategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        subcategory_id INTEGER NOT NULL,
        note TEXT,
        FOREIGN KEY (subcategory_id) REFERENCES subcategories (id) ON DELETE CASCADE
      )
    ''');
    
    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    final catDefs = [
      {'name': 'Food & Dining', 'icon': 'shoppingBag', 'color': '0xFFF59E0B', 'subs': ['Groceries', 'Restaurants', 'Coffee']},
      {'name': 'Transport', 'icon': 'car', 'color': '0xFF3B82F6', 'subs': ['Public Transit', 'Fuel', 'Taxi/Uber']},
      {'name': 'Utilities', 'icon': 'home', 'color': '0xFF10B981', 'subs': ['Internet', 'Electricity', 'Water']},
      {'name': 'Entertainment', 'icon': 'monitor', 'color': '0xFF8B5CF6', 'subs': ['Movies', 'Subscriptions', 'Games']},
      {'name': 'Health', 'icon': 'heart', 'color': '0xFFEF4444', 'subs': ['Pharmacy', 'Doctor', 'Fitness']},
    ];
    
    int catId = 1;
    for (var cat in catDefs) {
      await db.rawInsert("INSERT INTO categories (name, icon_code, color_hex) VALUES (?, ?, ?)", [cat['name'], cat['icon'], cat['color']]);
      for (var sub in cat['subs'] as List<String>) {
        await db.rawInsert("INSERT INTO subcategories (category_id, name) VALUES (?, ?)", [catId, sub]);
      }
      catId++;
    }
  }

  // --- Category CRUD ---
  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('categories');
    
    // Failsafe: if completely empty, seed them and fetch again.
    // This fixes empty dropdowns caused by hot reload skipping the onCreate step.
    if (maps.isEmpty) {
      await _seedCategories(db);
      maps = await db.query('categories');
    }
    
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }
  
  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- SubCategory CRUD ---
  Future<int> insertSubCategory(SubCategoryModel subCategory) async {
    final db = await database;
    return await db.insert('subcategories', subCategory.toMap());
  }

  Future<List<SubCategoryModel>> getSubCategories(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subcategories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => SubCategoryModel.fromMap(maps[i]));
  }

  Future<int> updateSubCategory(SubCategoryModel subCategory) async {
    final db = await database;
    return await db.update('subcategories', subCategory.toMap(), where: 'id = ?', whereArgs: [subCategory.id]);
  }

  Future<int> deleteSubCategory(int id) async {
    final db = await database;
    return await db.delete('subcategories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Transaction CRUD ---
  Future<int> insertTransaction(TransactionRecord transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }
  
  Future<double> getTotalSpendForDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;
    
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ?',
      [startMs, endMs]
    );
    
    if (result.first['total'] != null) {
      return result.first['total'] as double;
    }
    return 0.0;
  }
  
  Future<List<Map<String, dynamic>>> getCategoryBreakdown(DateTime date) async {
    final db = await database;
    
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;

    return await db.rawQuery('''
      SELECT c.name, c.icon_code, c.color_hex, SUM(t.amount) as total
      FROM transactions t
      JOIN subcategories s ON t.subcategory_id = s.id
      JOIN categories c ON s.category_id = c.id
      WHERE t.date >= ? AND t.date <= ?
      GROUP BY c.id
      ORDER BY total DESC
    ''', [startOfDay, endOfDay]);
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsWithCategories({DateTime? startDate, DateTime? endDate}) async {
    final db = await database;
    String query = '''
      SELECT 
        t.id as transaction_id, t.amount, t.date, t.note,
        s.name as subcategory_name,
        c.name as category_name, c.icon_code, c.color_hex
      FROM transactions t
      JOIN subcategories s ON t.subcategory_id = s.id
      JOIN categories c ON s.category_id = c.id
    ''';
    
    List<dynamic> args = [];
    if (startDate != null && endDate != null) {
      query += ' WHERE t.date >= ? AND t.date <= ?';
      args.addAll([startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    }
    
    query += ' ORDER BY t.date DESC';
    
    return await db.rawQuery(query, args);
  }

  Future<void> resetAllData() async {
    final db = await database;
    await db.execute('DELETE FROM transactions');
    await db.execute('DELETE FROM subcategories');
    await db.execute('DELETE FROM categories');
    
    // Reset auto-increment counters if sqlite_sequence exists
    try {
      await db.execute('DELETE FROM sqlite_sequence WHERE name IN ("transactions", "subcategories", "categories")');
    } catch (e) {
      // Ignore if sqlite_sequence doesn't exist
    }
    
    await _seedCategories(db);
  }
}
