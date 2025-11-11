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
  // 🧱 Inicialización de la base de datos
  // ------------------------------------------------------------
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ------------------------------------------------------------
  // 🧩 Creación de tablas
  // ------------------------------------------------------------
  Future<void> _createDB(Database db, int version) async {
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Si no existe la tabla symptoms, la crea
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
  //  Operaciones de Pacientes
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
  // 💉 Operaciones de Síntomas
  // ------------------------------------------------------------

  // Insertar síntoma
  Future<int> insertSymptom(Map<String, dynamic> symptom) async {
    final db = await instance.database;
    return await db.insert(
      'symptoms',
      symptom,
      conflictAlgorithm:
          ConflictAlgorithm.replace, // 👈 evita fallos silenciosos
    );
  }

  // Obtener todos los síntomas
  Future<List<Map<String, dynamic>>> getSymptoms() async {
    final db = await instance.database;
    return await db.query('symptoms', orderBy: 'date DESC');
  }

  // Obtener síntomas por paciente
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

  // Eliminar síntoma
  Future<int> deleteSymptom(int id) async {
    final db = await instance.database;
    return await db.delete('symptoms', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------------------------------------
  //  Cerrar base de datos
  // ------------------------------------------------------------
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
