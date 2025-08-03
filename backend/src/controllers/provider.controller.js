// backend/src/controllers/provider.controller.js

import { User } from '../models/user.model.js';

const getProvidersByService = async (req, res) => {
  try {
    const { serviceId } = req.query;
    if (!serviceId) {
      return res.status(400).json({ success: false, message: 'Service ID is required' });
    }

    // Find users who are providers, offer the specific service, AND are currently available.
    // Then, sort them by their average rating in descending order.
    const providers = await User.find({
      role: 'provider',
      service: serviceId,
      isAvailable: true,
    })
    .sort({ averageRating: -1 })
    .select('-password'); // Exclude password from the result

    return res.status(200).json(providers); // Send the array directly
  } catch (error) {
    console.error("Error fetching providers:", error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

export { getProvidersByService };