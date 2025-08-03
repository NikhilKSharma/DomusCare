// src/controllers/user.controller.js
// --- CORRECTED VERSION ---

import { User } from '../models/user.model.js';

// Get the profile of the currently logged-in user
const getMyProfile = async (req, res) => {
    return res.status(200).json({
        success: true,
        data: req.user
    });
};

// Update the profile of the currently logged-in user
const updateMyProfile = async (req, res) => {
    try {
        // --- FIX: Added 'service' to the destructuring ---
        const { name, phone, address, bio, basePrice, service } = req.body;
        const userId = req.user._id;

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            {
                // --- FIX: Added 'service' to the update object ---
                $set: { name, phone, address, bio, basePrice, service }
            },
            { new: true, runValidators: true }
        ).select('-password').populate('service');

        if (!updatedUser) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        return res.status(200).json({ success: true, data: updatedUser, message: 'Profile updated successfully' });
    } catch (error) {
        console.error("Error updating profile:", error);
        return res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

export { getMyProfile, updateMyProfile };