import express from "express";
import dbPromise from "../db/init.js";

const router = express.Router();

router.post("/:patientId", async (req, res) => {
  const { hrv, heart_rate, temperature } = req.body;
  const { patientId } = req.params;

  try {
    const db = await dbPromise;
    await db.run(
      "INSERT INTO biometrics (patient_id, hrv, heart_rate, temperature) VALUES (?, ?, ?, ?)",
      [patientId, hrv, heart_rate, temperature]
    );
    res.json({ message: "Biometric data saved" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get("/:patientId/evolution", async (req, res) => {
  const db = await dbPromise;
  const result = await db.get(
    "SELECT AVG(hrv) as avgHRV FROM biometrics WHERE patient_id = ?",
    [req.params.patientId]
  );
  res.json(result);
});

export default router;
