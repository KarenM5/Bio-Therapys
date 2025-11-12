import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('patients.db');
    return _database!;
  }

  // ------------------------------------------------------------
  // Inicialización de la base de datos
  // ------------------------------------------------------------
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5, // 🔄 Nueva versión para garantizar actualización
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ------------------------------------------------------------
  // Creación de tablas
  // ------------------------------------------------------------
  Future<void> _createDB(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('paciente','terapeuta'))
      )
    ''');

    // Tabla de pacientes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lastname TEXT,
        age INTEGER,
        weight REAL,
        heart_rate INTEGER,
        disease TEXT
      )
    ''');

    // Tabla de síntomas
    await db.execute('''
      CREATE TABLE IF NOT EXISTS symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        patientName TEXT,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');
  }

  // ------------------------------------------------------------
  // Actualización de versión (si ya existe la BD)
  // ------------------------------------------------------------
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          role TEXT NOT NULL CHECK(role IN ('paciente','terapeuta'))
        )
      ''');
    }
  }

  // ------------------------------------------------------------
  // 👤 Operaciones de Usuarios
  // ------------------------------------------------------------
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(
    String username,
    String password,
  ) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isNotEmpty) return result.first;
    return null;
  }

  // ------------------------------------------------------------
  // 🧍‍♀️ Operaciones de Pacientes
  // ------------------------------------------------------------
  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await instance.database;
    return await db.insert(
      'patients',
      patient,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await instance.database;
    return await db.query('patients', orderBy: 'id DESC');
  }

  Future<int> deletePatient(int id) async {
    final db = await instance.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------------------------------------
  // 🤒 Operaciones de Síntomas
  // ------------------------------------------------------------
  Future<int> insertSymptom(Map<String, dynamic> symptom) async {
    final db = await instance.database;
    return await db.insert(
      'symptoms',
      symptom,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSymptoms() async {
    final db = await instance.database;
    return await db.query('symptoms', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getSymptomsByPatientId(
    int patientId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'symptoms',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteSymptom(int id) async {
    final db = await instance.database;
    return await db.delete('symptoms', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------------------------------------
  // 🔒 Cerrar base de datos
  // ------------------------------------------------------------
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
