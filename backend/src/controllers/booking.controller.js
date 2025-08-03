// src/controllers/booking.controller.js
// --- UPDATED VERSION ---

import { Booking } from '../models/booking.model.js';
import { User } from '../models/user.model.js';

// createBooking function remains the same
const createBooking = async (req, res) => {
  try {
    const { providerId, serviceId, bookingTime, address } = req.body;
    const customerId = req.user._id;

    if (!providerId || !serviceId || !bookingTime || !address) {
      return res.status(400).json({ success: false, message: 'All fields are required' });
    }

    const provider = await User.findById(providerId);
    if (!provider || provider.role !== 'provider') {
      return res.status(404).json({ success: false, message: 'Provider not found' });
    }

    const newBooking = await Booking.create({
      customer: customerId,
      provider: providerId,
      service: serviceId,
      bookingTime: new Date(bookingTime),
      address,
      price: provider.basePrice,
    });

    return res.status(201).json({ success: true, data: newBooking });
  } catch (error) {
    console.error("Error creating booking:", error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// getBookings function remains the same
const getBookings = async (req, res) => {
  try {
    const user = req.user;
    let bookings;

    if (user.role === 'provider') {
      bookings = await Booking.find({ provider: user._id })
        .populate('customer', 'name phone profilePicture')
        .populate('service', 'name')
        .sort({ createdAt: -1 });
    } else {
      bookings = await Booking.find({ customer: user._id })
        .populate('provider', 'name phone profilePicture')
        .populate('service', 'name')
        .sort({ createdAt: -1 });
    }

    return res.status(200).json({ success: true, data: bookings });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// --- THIS FUNCTION IS UPDATED ---
const updateBookingStatus = async (req, res) => {
  try {
    const { bookingId } = req.params;
    const { status } = req.body;
    const providerId = req.user._id;

    const booking = await Booking.findById(bookingId);

    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    if (booking.provider.toString() !== providerId.toString()) {
      return res.status(403).json({ success: false, message: 'User not authorized to update this booking' });
    }

    booking.status = status;
    await booking.save();

    // --- NEW LOGIC ---
    // If the job is being marked as 'Completed', increment the provider's job counter.
    if (status === 'Completed') {
        await User.findByIdAndUpdate(providerId, { $inc: { completedJobs: 1 } });
    }
    // -----------------

    return res.status(200).json({ success: true, data: booking });
  } catch (error) {
    console.error("Error updating booking status:", error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

export { createBooking, getBookings, updateBookingStatus };