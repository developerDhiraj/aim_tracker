
import 'dart:convert';

import 'package:aim_tracker/models/activity_log.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ActtivityDatabase {
  static final ActtivityDatabase instance = ActtivityDatabase._init();
  static Database? _database;
  ActtivityDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('activites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${ActivityFields.tableName}(
      ${ActivityFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${ActivityFields.title} TEXT NOT NULL,
      ${ActivityFields.total} INTEGER NOT NULL,
      ${ActivityFields.lastDone} TEXT
      )
      '''
    );
    
    await db.execute('''
    CREATE TABLE user(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    imagePath TEXT
    ) 
    ''');
    
    
    //Default user name

    await db.insert('user', {'name': 'Demo', 'imagePath' : ''});


    // Default 4 task insert

    await db.insert(ActivityFields.tableName, {
      ActivityFields.title: 'Task 1',
      ActivityFields.total: 0,
      ActivityFields.lastDone: null,
    });

    await db.insert(ActivityFields.tableName, {
      ActivityFields.title: 'Task 2',
      ActivityFields.total: 0,
      ActivityFields.lastDone: null,
    });

    await db.insert(ActivityFields.tableName, {
      ActivityFields.title: 'Task 3',
      ActivityFields.total: 0,
      ActivityFields.lastDone: null,
    });

    await db.insert(ActivityFields.tableName, {
      ActivityFields.title: 'Task 4',
      ActivityFields.total: 0,
      ActivityFields.lastDone: null,
    });
  }

  // ✅ Function to Save or Update User Data

  Future<void> saveUserData(String name, String? imagePath) async {
    final db = await instance.database;
    final result = await db.query('user');

    if (result.isEmpty){
      await db.insert('user', {'name': name, 'imagePath': imagePath});
    } else {
      await db.update('user', {'name': name, 'imagePath': imagePath});
    }
    print("User data Saved : $name, $imagePath");
  }

  Future<Map<String, dynamic>?>getUserData() async {
    final db = await instance.database;
    final result = await db.query('user');
    if (result.isNotEmpty){
      return result.first;
    }
    return null;
  }

  //Create

  Future<Activity> create(Activity activity) async {
    final db = await instance.database;
    final id = await db.insert(ActivityFields.tableName, activity.toJson());
    return activity.copy(id: id);
  }
 // Read One
  Future<Activity?> readActivity(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      ActivityFields.tableName,
      columns: ActivityFields.values,
      where: '${ActivityFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty){
      return Activity.fromJson(maps.first);
    }else{
      return null;
    }
  }
 // Read All
  Future<List<Activity>> readAllActivities() async {
    final db = await instance.database;
    final result = await db.query(ActivityFields.tableName);
    return result.map((json)=> Activity.fromJson(json)).toList();
  }

  // Update

 Future<int> update(Activity activity) async {
    final db = await instance.database;
    return db.update(
      ActivityFields.tableName,
      activity.toJson(),
      where: '${ActivityFields.id} = ?',
      whereArgs: [activity.id],);
 }
  // Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete(
      ActivityFields.tableName,
    where: '${ActivityFields.id} = ?',
        whereArgs: [id],
    );
  }
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}