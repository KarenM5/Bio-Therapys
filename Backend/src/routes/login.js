import { Router } from "express";
const router = Router();
import dbPromise from "../db/init.js";
import bcrypt from "bcrypt";

router.post("/", async (req, res) => {
  const { email, password } = req.body;

  // Validación básica
  if (!email || !password) {
    return res.status(400).json({ error: "Email y contraseña requeridos" });
  }

  try {
    const db = await dbPromise;
    const user = await db.get("SELECT * FROM users WHERE email = ?", [email]);

    if (!user) {
      return res.status(401).json({ error: "Usuario no encontrado" });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: "Contraseña incorrecta" });
    }

    res.json({
      message: "Login exitoso",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    console.error("❌ Error en login:", error);
    res.status(500).json({ error: "Error interno en el servidor" });
  }
});

export default router;