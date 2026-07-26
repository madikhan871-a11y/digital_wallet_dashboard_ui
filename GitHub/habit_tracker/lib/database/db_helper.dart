import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/habit_model.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), "habits.db");

    return await openDatabase(
      path,
      version: 2, // Database Version Updated
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isCompleted INTEGER,
            streak INTEGER,
            lastCompletedDate TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE habits ADD COLUMN streak INTEGER DEFAULT 0");

          await db.execute(
              "ALTER TABLE habits ADD COLUMN lastCompletedDate TEXT");
        }
      },
    );
  }

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert("habits", habit.toMap());
  }

  Future<List<Habit>> getHabits() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query("habits");

    return List.generate(
      maps.length,
          (i) => Habit.fromMap(maps[i]),
    );
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;

    return await db.update(
      "habits",
      habit.toMap(),
      where: "id=?",
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;

    return await db.delete(
      "habits",
      where: "id=?",
      whereArgs: [id],
    );
  }
}