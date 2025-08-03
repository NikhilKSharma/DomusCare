// src/controllers/review.controller.js
// --- CORRECTED VERSION ---

import { Review } from '../models/review.model.js';
import { Booking } from '../models/booking.model.js';
import { User } from '../models/user.model.js';
import mongoose from 'mongoose'; // <-- THIS LINE IS FIXED

// --- HELPER FUNCTION to recalculate average rating ---
const updateProviderRating = async (providerId) => {
    const reviews = await Review.find({ provider: providerId });

    if (reviews.length === 0) {
        await User.findByIdAndUpdate(providerId, { averageRating: 0 });
        return;
    }

    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    const newAverage = parseFloat((totalRating / reviews.length).toFixed(1));

    await User.findByIdAndUpdate(providerId, { averageRating: newAverage });
};


// --- MAIN FUNCTION to create a review ---
const createReview = async (req, res) => {
  try {
    const { bookingId, rating, comment } = req.body;
    const customerId = req.user._id;

    const booking = await Booking.findById(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }

    if (booking.customer.toString() !== customerId.toString()) {
      return res.status(403).json({ success: false, message: "You are not authorized to review this booking" });
    }

    if (booking.status !== 'Completed') {
      return res.status(400).json({ success: false, message: "Cannot review a booking that is not completed" });
    }
    
    const existingReview = await Review.findOne({ booking: bookingId });
    if (existingReview) {
        return res.status(409).json({ success: false, message: "This booking has already been reviewed" });
    }

    const newReview = await Review.create({
      booking: bookingId,
      customer: customerId,
      provider: booking.provider,
      rating,
      comment,
    });

    await updateProviderRating(booking.provider);

    return res.status(201).json({ success: true, data: newReview });
  } catch (error) {
    console.error("Error creating review:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

// --- This function was added in the previous step ---
const getReviewsForProvider = async (req, res) => {
    try {
        const { providerId } = req.params;
        const reviews = await Review.find({ provider: providerId })
            .populate('customer', 'name profilePicture')
            .sort({ createdAt: -1 });

        return res.status(200).json({ success: true, data: reviews });
    } catch (error) {
        console.error("Error fetching reviews:", error);
        return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

export { createReview, getReviewsForProvider };