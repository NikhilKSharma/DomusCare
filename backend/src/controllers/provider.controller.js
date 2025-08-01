// src/controllers/provider.controller.js
import { User } from '../models/user.model.js';

const getProvidersByService = async (req, res) => {
  const { serviceId } = req.query;
  if (!serviceId) {
    return res.status(400).json({ message: 'Service ID is required' });
  }

  // Find users who are providers, offer the specific service, AND are currently available.
  // Then, sort them by their average rating in descending order.
  const providers = await User.find({
    role: 'provider',
    services: serviceId,
    isAvailable: true, // <-- NEW: Only find available providers
  })
  .sort({ averageRating: -1 }) // <-- NEW: Sort by highest rating
  .select('-password');

  res.status(200).json(providers);
};

export { getProvidersByService };