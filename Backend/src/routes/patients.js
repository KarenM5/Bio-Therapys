import express from "express";
import dbPromise from "../db/init.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const db = await dbPromise;
  const patients = await db.all(
    `SELECT p.id, u.name, u.email FROM patients p 
     JOIN users u ON u.id = p.user_id`
  );
  res.json(patients);
});

router.get("/:id", async (req, res) => {
  const db = await dbPromise;
  const patient = await db.get(
    `SELECT u.name, u.email, b.hrv, b.heart_rate, b.temperature, b.created_at
     FROM patients p
     JOIN users u ON u.id = p.user_id
     LEFT JOIN biometrics b ON b.patient_id = p.id
     WHERE p.id = ?`,
    [req.params.id]
  );
  res.json(patient);
});

export default router;
