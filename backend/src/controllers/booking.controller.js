// src/controllers/booking.controller.js

import { Booking } from '../models/booking.model.js';
import { User } from '../models/user.model.js';

const createBooking = async (req, res) => {
    // ... this function remains the same
};

// --- NEW FUNCTION: Get bookings for the logged-in user ---
const getBookings = async (req, res) => {
  try {
    const user = req.user;
    let bookings;

    if (user.role === 'provider') {
      // If user is a provider, find bookings assigned to them
      bookings = await Booking.find({ provider: user._id })
        .populate('customer', 'name phone profilePicture') // Get customer details
        .populate('service', 'name') // Get service name
        .sort({ createdAt: -1 }); // Show newest first
    } else {
      // If user is a customer, find bookings they created
      bookings = await Booking.find({ customer: user._id })
        .populate('provider', 'name phone profilePicture') // Get provider details
        .populate('service', 'name')
        .sort({ createdAt: -1 });
    }

    return res.status(200).json({ success: true, data: bookings });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// --- NEW FUNCTION: Update the status of a booking ---
const updateBookingStatus = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { status } = req.body; // e.g., "Accepted", "Cancelled"
    const providerId = req.user._id;

    const booking = await Booking.findById(bookingId);

    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    // Security Check: Ensure the logged-in user is the provider for this booking
    if (booking.provider.toString() !== providerId.toString()) {
      return res.status(403).json({ success: false, message: 'User not authorized to update this booking' });
    }

    booking.status = status;
    await booking.save();

    return res.status(200).json({ success: true, data: booking });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

export { createBooking, getBookings, updateBookingStatus };