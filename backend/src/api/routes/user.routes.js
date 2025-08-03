// src/api/routes/user.routes.js
import { Router } from 'express';
import { getMyProfile, updateMyProfile } from '../../controllers/user.controller.js';
import { verifyJWT } from '../../middlewares/auth.middleware.js';

const router = Router();

// All routes in this file will require a valid JWT
router.use(verifyJWT);

router.route('/me')
  .get(getMyProfile)
  .put(updateMyProfile);

export default router;