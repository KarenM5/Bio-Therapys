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

  // Crear tabla de usuarios
  await db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT UNIQUE,
      password TEXT,
      role TEXT CHECK(role IN ('patient', 'therapist'))
    )
  `);

  console.log("Base de datos inicializada en:", dbPath);
})();

export default dbPromise;
