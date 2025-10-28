import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        lastname TEXT,
        age INTEGER,
        disease TEXT,
        weight REAL
        height REAL,
        heart_rate INTEGER,
        email TEXT,
        image_path TEXT,
        consent INTEGER,
        registration_date TEXT
      )
    ''');
  }

   Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE patients ADD COLUMN height REAL');
      await db.execute('ALTER TABLE patients ADD COLUMN heart_rate INTEGER');
      await db.execute('ALTER TABLE patients ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE patients ADD COLUMN image_path TEXT');
      await db.execute('ALTER TABLE patients ADD COLUMN consent INTEGER');
      await db.execute('ALTER TABLE patients ADD COLUMN registration_date TEXT');
    }
  }

  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await instance.database;
    return await db.insert('patients', patient);
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await instance.database;
    return await db.query('patients');
  }

  Future<int> deletePatient(int id) async {
    final db = await instance.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }
}
