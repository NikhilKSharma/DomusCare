// src/controllers/user.controller.js
import { User } from '../models/user.model.js';

// Get the profile of the currently logged-in user
const getMyProfile = async (req, res) => {
    // The user object is attached to the request by our verifyJWT middleware
    // We just need to send it back.
    return res.status(200).json({
        success: true,
        data: req.user
    });
};

// Update the profile of the currently logged-in user
const updateMyProfile = async (req, res) => {
    try {
        const { name, phone, address, bio, basePrice } = req.body;
        const userId = req.user._id;

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            {
                $set: { name, phone, address, bio, basePrice }
            },
            { new: true, runValidators: true } // Return the updated document
        ).select('-password');

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