import express from "express";
import dbPromise from "../db/init.js";

const router = express.Router();


router.get("/", async (req, res) => {
  const db = await dbPromise;
  const therapists = await db.all(
    "SELECT t.id, u.name, u.email FROM therapists t JOIN users u ON u.id = t.user_id"
  );
  res.json(therapists);
});


router.post("/assign", async (req, res) => {
  const { therapistId, patientId } = req.body;
 
  res.json({ message: "Feature pending: assign therapist to patient" });
});

export default router;
