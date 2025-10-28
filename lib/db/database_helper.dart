import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('biotherapys.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        lastname TEXT,
        email TEXT,
        age INTEGER,
        height REAL,
        weight REAL,
        disease TEXT,
        heartRate INTEGER,
        consent INTEGER,
        imagePath TEXT,
        createdAt TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE patients ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE patients ADD COLUMN height REAL');
      await db.execute('ALTER TABLE patients ADD COLUMN heartRate INTEGER');
      await db.execute('ALTER TABLE patients ADD COLUMN imagePath TEXT');
      await db.execute('ALTER TABLE patients ADD COLUMN consent INTEGER');
      await db.execute('ALTER TABLE patients ADD COLUMN createdAt TEXT');
    }
  }

  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await instance.database;
    return await db.insert('patients', patient);
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await instance.database;
    return await db.query('patients', orderBy: 'id DESC');
  }

  Future<int> deletePatient(int id) async {
    final db = await instance.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }
}
