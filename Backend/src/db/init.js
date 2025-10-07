import sqlite3 from "sqlite3";
import { open } from "sqlite";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const dbPath = path.resolve(__dirname, "database.sqlite");

if (!fs.existsSync(dbPath)) {
  console.log("No existe la base de datos, se creará una nueva");
}

const dbPromise = open({
  filename: dbPath,
  driver: sqlite3.Database,
});

(async () => {
  const db = await dbPromise;

  await db.exec("PRAGMA foreign_keys = ON;");

  await db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT CHECK(role IN ('patient', 'therapist')) NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  const existingAdmin = await db.get("SELECT * FROM users WHERE email = ?", ["admin"]);
  if (!existingAdmin) {
    const bcrypt = await import('bcrypt');
    const hashedPassword = await bcrypt.default.hash("admin", 10);
    await db.run(
      "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)",
      ["Administrador", "admin", hashedPassword, "therapist"]
    );
    console.log("✅ Usuario admin creado");
  }

  await db.exec(`
    CREATE TABLE IF NOT EXISTS biometric_data (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      face_template BLOB,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS patient_profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      age INTEGER,
      gender TEXT,
      medical_conditions TEXT,
      emergency_contact TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS therapist_profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      specialization TEXT,
      license_number TEXT,
      years_experience INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS patient_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_id INTEGER NOT NULL,
      therapist_id INTEGER,
      heart_rate_variability FLOAT,
      observations TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (patient_id) REFERENCES patient_profile(id) ON DELETE CASCADE,
      FOREIGN KEY (therapist_id) REFERENCES therapist_profile(id) ON DELETE SET NULL
    );
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS therapy_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_id INTEGER NOT NULL,
      therapist_id INTEGER NOT NULL,
      session_date DATETIME NOT NULL,
      notes TEXT,
      emotion_score INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (patient_id) REFERENCES patient_profile(id) ON DELETE CASCADE,
      FOREIGN KEY (therapist_id) REFERENCES therapist_profile(id) ON DELETE CASCADE
    );
  `);

  await db.exec(`
    CREATE TABLE IF NOT EXISTS alerts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      patient_id INTEGER NOT NULL,
      message TEXT NOT NULL,
      alert_type TEXT,
      status TEXT DEFAULT 'active' CHECK(status IN ('active', 'resolved')),
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (patient_id) REFERENCES patient_profile(id) ON DELETE CASCADE
    );
  `);

  console.log("✅ Base de datos inicializada correctamente en:", dbPath);
})();

export default dbPromise;