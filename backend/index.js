// backend/index.js

import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose';

// Import Routers
import authRouter from './src/api/routes/auth.routes.js';
import serviceRouter from './src/api/routes/service.routes.js'; // <-- This line is new

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

// Middlewares
app.use(cors({
  origin: '*',
  methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
  credentials: true
}));
app.use(express.json());

// --- Connect to MongoDB ---
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log("✅ MongoDB connected successfully!");
  })
  .catch((error) => {
    console.error("❌ MongoDB connection error:", error);
    process.exit(1);
  });
// -------------------------

// --- API Routes ---
const apiVersion = '/api/v1';
app.use(`${apiVersion}/auth`, authRouter);
app.use(`${apiVersion}/services`, serviceRouter); // <-- This line is new
// --------------------

// A simple test route
app.get('/', (req, res) => {
  res.send('DomusCare API is running! 🚀');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});