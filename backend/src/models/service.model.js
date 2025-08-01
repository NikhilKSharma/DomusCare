// backend/src/models/service.model.js

import mongoose from 'mongoose';

const serviceSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    trim: true,
  },
  icon: {
    type: String, // You can store an icon name or a URL to an image
    required: true,
  },
}, { timestamps: true });

export const Service = mongoose.model('Service', serviceSchema);