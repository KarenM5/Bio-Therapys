import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.js";
import patientRoutes from "./routes/patients.js";
import therapistRoutes from "./routes/therapists.js";
import biometricRoutes from "./routes/biometrics.js";

const app = express();
app.use(cors());
app.use(express.json());


app.use("/auth", authRoutes);
app.use("/patients", patientRoutes);
app.use("/therapists", therapistRoutes);
app.use("/biometrics", biometricRoutes);

const PORT = 4000;
app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));
