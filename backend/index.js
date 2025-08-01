// backend/index.js
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose'; 

import authRouter from './src/api/routes/auth.routes.js';
import serviceRouter from './src/api/routes/service.routes.js'; // <-- Verify this line exists
import providerRouter from './src/api/routes/provider.routes.js';
// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 8000;

// Middlewares
// Replace the simple app.use(cors()); with this:
app.use(cors({
  origin: '*', // Allow all origins
  methods: "GET,HEAD,PUT,PATCH,POST,DELETE",
  credentials: true // Allow cookies to be sent
})); // Enable Cross-Origin Resource Sharing


app.use(express.json()); // Enable parsing of JSON bodies

// --- Connect to MongoDB ---
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log("✅ MongoDB connected successfully!");
  })
  .catch((error) => {
    console.error("❌ MongoDB connection error:", error);
    process.exit(1); // Exit process with failure
  });
// -------------------------

// --- API Routes ---
const apiVersion = '/api/v1';
app.use(`${apiVersion}/auth`, authRouter);
app.use(`${apiVersion}/services`, serviceRouter); // <-- Verify this line exists
app.use(`${apiVersion}/providers`, providerRouter);
// --------------------


// A simple test route
app.get('/', (req, res) => {
  res.send('DomusCare API is running! 🚀');
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});