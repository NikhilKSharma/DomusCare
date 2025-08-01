// src/api/routes/auth.routes.js
import { Router } from 'express';
import { registerUser, loginUser } from '../../controllers/auth.controller.js';

const router = Router();

// Define routes
router.route('/register').post(registerUser);
router.route('/login').post(loginUser);

export default router;