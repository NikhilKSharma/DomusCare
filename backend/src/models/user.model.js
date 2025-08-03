// src/models/user.model.js
import mongoose from 'mongoose';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

const userSchema = new mongoose.Schema(
  {
    // ... existing fields (name, email, phone, password, role)
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    phone: { type: String, required: true, unique: true, trim: true },
    password: { type: String, required: [true, 'Password is required'] },
    role: { type: String, enum: ['customer', 'provider'], default: 'customer', required: true },

    // --- EXISTING PROVIDER FIELDS ---
    profilePicture: { type: String, default: '' },
    bio: { type: String, default: '' },
service: { // Provider's single service
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Service',
},
    basePrice: { type: Number, default: 0 },
    averageRating: { type: Number, default: 0 },

    // --- NEWLY ADDED FIELDS ---
    address: { // For customers
      type: String,
      default: '',
    },
    isAvailable: { // For providers to toggle their status
      type: Boolean,
      default: true,
    },
    completedJobs: { // For providers
      type: Number,
      default: 0,
    },
    // --------------------------
  },
  { timestamps: true }
);

// Mongoose middleware to hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

// Method to check if the entered password is correct
userSchema.methods.isPasswordCorrect = async function (password) {
  return await bcrypt.compare(password, this.password);
};

// Method to generate a JWT access token
userSchema.methods.generateAccessToken = function () {
  return jwt.sign(
    {
      _id: this._id,
      email: this.email,
      role: this.role,
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.ACCESS_TOKEN_EXPIRY || '1d',
    }
  );
};

export const User = mongoose.model('User', userSchema);