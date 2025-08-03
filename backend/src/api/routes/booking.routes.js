// src/api/routes/booking.routes.js

import { Router } from 'express';
import { createBooking, getBookings, updateBookingStatus } from '../../controllers/booking.controller.js';
import { verifyJWT } from '../../middlewares/auth.middleware.js';

const router = Router();

// All booking routes will be protected by the JWT middleware
router.use(verifyJWT);

// POST /api/v1/bookings/ (Create a new booking)
// GET  /api/v1/bookings/ (Get bookings for the logged-in user)
router.route('/')
  .post(createBooking)
  .get(getBookings);

// PATCH /api/v1/bookings/:bookingId/status (Update a booking's status)
router.route('/:bookingId/status').patch(updateBookingStatus);

export default router;