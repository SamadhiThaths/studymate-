import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/study_task.dart';
import '../models/expense.dart';
import '../models/assignment.dart';
import '../models/notification.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  static Database? _database;

  // Singleton pattern
  factory DBService() => _instance;

  DBService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasl_database.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL
      );
    ''');

    // Create study_tasks table
    await db.execute('''
      CREATE TABLE study_tasks (
        id TEXT PRIMARY KEY,
        subject TEXT NOT NULL,
        task TEXT NOT NULL,
        date INTEGER NOT NULL,
        durationMinutes INTEGER NOT NULL,
        isDone INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL
      );
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      );
    ''');
    
    // Create assignments table
    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        moduleCode TEXT NOT NULL,
        dueDate INTEGER NOT NULL,
        status TEXT NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL
      );
    ''');
    
    // Create notifications table
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        relatedEntityId TEXT,
        relatedEntityType TEXT
      );
    ''');
  }

  // Generic methods for CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await database;
    String id = data['id'];
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Task specific methods
  Future<List<Task>> getAllTasks() async {
    final List<Map<String, dynamic>> maps = await getAll('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> insertTask(Task task) async {
    return await insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    return await update('tasks', task.toMap());
  }

  Future<int> deleteTask(String id) async {
    return await delete('tasks', id);
  }

  // StudyTask specific methods
  Future<List<StudyTask>> getAllStudyTasks() async {
    final List<Map<String, dynamic>> maps = await getAll('study_tasks');
    return List.generate(maps.length, (i) => StudyTask.fromMap(maps[i]));
  }

  Future<List<StudyTask>> getStudyTasksByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'study_tasks',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay, endOfDay],
    );
    
    return List.generate(maps.length, (i) => StudyTask.fromMap(maps[i]));
  }

  Future<List<StudyTask>> getStudyTasksBySubject(String subject) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_tasks',
      where: 'subject = ?',
      whereArgs: [subject],
    );
    
    return List.generate(maps.length, (i) => StudyTask.fromMap(maps[i]));
  }

  Future<int> insertStudyTask(StudyTask studyTask) async {
    return await insert('study_tasks', studyTask.toMap());
  }

  Future<int> updateStudyTask(StudyTask studyTask) async {
    return await update('study_tasks', studyTask.toMap());
  }

  Future<int> deleteStudyTask(String id) async {
    return await delete('study_tasks', id);
  }

  // Expense specific methods
  Future<List<Expense>> getAllExpenses() async {
    final List<Map<String, dynamic>> maps = await getAll('expenses');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startTimestamp, endTimestamp],
    );
    
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'category = ?',
      whereArgs: [category],
    );
    
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<int> insertExpense(Expense expense) async {
    return await insert('expenses', expense.toMap());
  }

  Future<int> updateExpense(Expense expense) async {
    return await update('expenses', expense.toMap());
  }

  Future<int> deleteExpense(String id) async {
    return await delete('expenses', id);
  }
  
  // Assignment specific methods
  Future<List<Assignment>> getAllAssignments() async {
    final List<Map<String, dynamic>> maps = await getAll('assignments');
    return List.generate(maps.length, (i) => Assignment.fromMap(maps[i]));
  }
  
  Future<List<Assignment>> getAssignmentsByStatus(String status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assignments',
      where: 'status = ?',
      whereArgs: [status],
    );
    
    return List.generate(maps.length, (i) => Assignment.fromMap(maps[i]));
  }
  
  Future<List<Assignment>> getAssignmentsByModule(String moduleCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'assignments',
      where: 'moduleCode = ?',
      whereArgs: [moduleCode],
    );
    
    return List.generate(maps.length, (i) => Assignment.fromMap(maps[i]));
  }
  
  Future<List<Assignment>> getAssignmentsByDueDate(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'assignments',
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [startTimestamp, endTimestamp],
    );
    
    return List.generate(maps.length, (i) => Assignment.fromMap(maps[i]));
  }
  
  Future<int> insertAssignment(Assignment assignment) async {
    return await insert('assignments', assignment.toMap());
  }
  
  Future<int> updateAssignment(Assignment assignment) async {
    return await update('assignments', assignment.toMap());
  }
  
  Future<int> deleteAssignment(String id) async {
    return await delete('assignments', id);
  }
  
  // Notification specific methods
  Future<List<Notification>> getAllNotifications() async {
    final List<Map<String, dynamic>> maps = await getAll('notifications');
    return List.generate(maps.length, (i) => Notification.fromMap(maps[i]));
  }
  
  Future<List<Notification>> getUnreadNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: 'isRead = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
    
    return List.generate(maps.length, (i) => Notification.fromMap(maps[i]));
  }
  
  Future<int> insertNotification(Notification notification) async {
    return await insert('notifications', notification.toMap());
  }
  
  Future<int> updateNotification(Notification notification) async {
    return await update('notifications', notification.toMap());
  }
  
  Future<int> markNotificationAsRead(String id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> markAllNotificationsAsRead() async {
    final db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
    );
  }
  
  Future<int> deleteNotification(String id) async {
    return await delete('notifications', id);
  }
  
  Future<int> deleteAllNotifications() async {
    final db = await database;
    return await db.delete('notifications');
  }
  
  // Database upgrade method
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add notifications table in version 2
      await db.execute('''
        CREATE TABLE notifications (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0,
          relatedEntityId TEXT,
          relatedEntityType TEXT
        );
      ''');
    }
  }
}