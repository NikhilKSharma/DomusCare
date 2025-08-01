// backend/src/api/routes/service.routes.js

import { Router } from 'express';
import { createService, getAllServices } from '../../controllers/service.controller.js';

const router = Router();

// This route handles two methods on the same path ('/'):
// A POST request will run createService
// A GET request will run getAllServices
router.route('/')
  .post(createService)
  .get(getAllServices);

export default router;