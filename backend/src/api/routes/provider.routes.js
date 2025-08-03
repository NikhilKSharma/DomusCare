// backend/src/api/routes/provider.routes.js

import { Router } from 'express';
import { getProvidersByService } from '../../controllers/provider.controller.js';

const router = Router();

// This handles a GET request to the root ('/') of this router
router.route('/').get(getProvidersByService);

export default router;