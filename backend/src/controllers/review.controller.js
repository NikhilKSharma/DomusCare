// src/controllers/review.controller.js
import { Review } from '../models/review.model.js';
import { Booking } from '../models/booking.model.js';
import { User } from '../models/user.model.js';
import mongoose, { PopulatedDoc } from 'mongoose';

// --- HELPER FUNCTION to recalculate average rating ---
const getReviewsForProvider = async (req, res) => {
    try {
        const { providerId } = req.params;
        const reviews = await Review.find({ provider: providerId })
            .populate('customer', 'name profilePicture') // Get the customer's name and picture
            .sort({ createdAt: -1 });

        return res.status(200).json({ success: true, data: reviews });
    } catch (error) {
        console.error("Error fetching reviews:", error);
        return res.status(500).json({ success: false, message: "Internal Server Error" });
    }
};

const updateProviderRating = async (providerId) => {
    // Find all reviews for the given provider
    const reviews = await Review.find({ provider: providerId });

    if (reviews.length === 0) {
        await User.findByIdAndUpdate(providerId, { averageRating: 0 });
        return;
    }

    // Calculate the sum of all ratings
    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    // Calculate the new average, rounded to one decimal place
    const newAverage = parseFloat((totalRating / reviews.length).toFixed(1));

    // Update the provider's user document with the new average rating
    await User.findByIdAndUpdate(providerId, { averageRating: newAverage });
};


// --- MAIN FUNCTION to create a review ---
const createReview = async (req, res) => {
  try {
    const { bookingId, rating, comment } = req.body;
    const customerId = req.user._id;

    // 1. Find the booking
    const booking = await Booking.findById(bookingId);
    if (!booking) {
      return res.status(404).json({ success: false, message: "Booking not found" });
    }

    // 2. Authorization Check: Ensure the logged-in user is the customer for this booking
    if (booking.customer.toString() !== customerId.toString()) {
      return res.status(403).json({ success: false, message: "You are not authorized to review this booking" });
    }

    // 3. Status Check: Ensure the booking is completed
    if (booking.status !== 'Completed') {
      return res.status(400).json({ success: false, message: "Cannot review a booking that is not completed" });
    }

    // 4. Uniqueness Check: Ensure this booking hasn't been reviewed already
    const existingReview = await Review.findOne({ booking: bookingId });
    if (existingReview) {
        return res.status(409).json({ success: false, message: "This booking has already been reviewed" });
    }

    // 5. Create the new review
    const newReview = await Review.create({
      booking: bookingId,
      customer: customerId,
      provider: booking.provider,
      rating,
      comment,
    });

    // 6. After creating the review, update the provider's average rating
    await updateProviderRating(booking.provider);

    return res.status(201).json({ success: true, data: newReview });
  } catch (error) {
    console.error("Error creating review:", error);
    return res.status(500).json({ success: false, message: "Internal Server Error" });
  }
};

export { createReview, getReviewsForProvider };