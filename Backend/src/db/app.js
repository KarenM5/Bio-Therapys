import express from "express";
import bodyParser from "body-parser";
import bcrypt from "bcrypt";
import dbPromise from "./db/init.js";

const app = express();
app.use(bodyParser.json());

app.post("/users", async (req, res) => {
  const { name, email, password, role } = req.body;
  try {
    const db = await dbPromise;
    const hashedPassword = await bcrypt.hash(password, 10);

    await db.run(
      "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)",
      [name, email, hashedPassword, role]
    );

    res.status(201).json({ message: "Usuario creado ✅" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al crear usuario" });
  }
});

app.get("/users", async (req, res) => {
  try {
    const db = await dbPromise;
    const users = await db.all("SELECT id, name, email, role FROM users");
    res.json(users);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Error al obtener usuarios" });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(` Servidor corriendo en http://localhost:${PORT}`);
});
