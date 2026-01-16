import 'package:apq_m1/Models/ModelsAuth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databaseauth {
  static Database? _db;

  static Future<List<Map<String, dynamic>>> getAllAuth() async {
    final db = await database;
    final result = await db.query('auth');
    return result;
  }

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'auth.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE auth (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            domain TEXT,
            username TEXT,
            data TEXT,
            node Text
          )
        ''');
      },
    );
  }

  static Future<void> saveAuth(Modelsauth auth) async {
    final db = await database;
    await db.delete('auth'); 
    await db.insert('auth', auth.toMap());
  }

  static Future<Modelsauth?> getAuth() async {
    final db = await database;
    final result = await db.query('auth', limit: 1);

    if (result.isEmpty) return null;

    return Modelsauth(
      domain: result.first['domain'] as String,
      username: result.first['username'] as String,
      data: result.first['data'] as dynamic,
      node: result.first['node'] as String? ?? '',
    );
  }

  static Future<void> logout() async {
    final db = await database;
    await db.delete('auth');
  }
}
