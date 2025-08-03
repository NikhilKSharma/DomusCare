// backend/index.js
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose';

import authRouter from './src/api/routes/auth.routes.js';
import serviceRouter from './src/api/routes/service.routes.js';
import providerRouter from './src/api/routes/provider.routes.js';
import bookingRouter from './src/api/routes/booking.routes.js';
import reviewRouter from './src/api/routes/review.routes.js';
import userRouter from './src/api/routes/user.routes.js'; // <-- This line is new

dotenv.config();
const app = express();
const PORT = process.env.PORT || 8000;

app.use(cors({ origin: '*', methods: "GET,HEAD,PUT,PATCH,POST,DELETE", credentials: true }));
app.use(express.json());

mongoose.connect(process.env.MONGODB_URI)
  .then(() => { console.log("✅ MongoDB connected successfully!"); })
  .catch((error) => { console.error("❌ MongoDB connection error:", error); process.exit(1); });

const apiVersion = '/api/v1';
app.use(`${apiVersion}/auth`, authRouter);
app.use(`${apiVersion}/services`, serviceRouter);
app.use(`${apiVersion}/providers`, providerRouter);
app.use(`${apiVersion}/bookings`, bookingRouter);
app.use(`${apiVersion}/reviews`, reviewRouter);
app.use(`${apiVersion}/users`, userRouter); // <-- This line is new

app.get('/', (req, res) => { res.send('DomusCare API is running! 🚀'); });
app.listen(PORT, () => { console.log(`Server is running on port ${PORT}`); });