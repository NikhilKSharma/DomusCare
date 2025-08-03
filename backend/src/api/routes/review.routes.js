// src/api/routes/review.routes.js

import { Router } from 'express';
import { createReview, getReviewsForProvider } from '../../controllers/review.controller.js';
import { verifyJWT } from '../../middlewares/auth.middleware.js';

const router = Router();

// A user must be logged in to create a review
router.route('/').post(verifyJWT, createReview);
router.route('/provider/:providerId').get(getReviewsForProvider);
export default router;