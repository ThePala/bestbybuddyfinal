import 'dart:async';
import 'package:bestbybuddy/globals.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:bestbybuddy/loginpage.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor(username);
  static Database? _database;

  final String _username; // Store the username

  DatabaseHelper._privateConstructor(this._username); // Receive username in constructor

  static final String tableName = 'foods';
  static final String columnId = 'id';
  static final String columnName = 'name';
  static final String columnBoughtOn = 'boughton';
  static final String columnExpiresOn = 'expireson';
  static final String columnDaysToNotify = 'daystonotify';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), '$_username.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT,
        $columnBoughtOn TEXT,
        $columnExpiresOn TEXT,
        $columnDaysToNotify INT
      )
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(tableName, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> insertFood(Map<String, dynamic> food) async {
    Database db = await database;
    return await db.insert(tableName, food);
  }
}