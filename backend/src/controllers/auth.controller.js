// src/controllers/auth.controller.js
import { User } from '../models/user.model.js';

// --- User Registration ---
const registerUser = async (req, res) => {
  const { name, email, phone, password, role } = req.body;

  if ([name, email, phone, password, role].some((field) => !field || field.trim() === '')) {
    return res.status(400).json({ success: false, message: 'All fields are required' });
  }

  const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
  if (existingUser) {
    return res.status(409).json({ success: false, message: 'User with this email or phone already exists' });
  }

  try {
    const user = await User.create({
      name,
      email,
      phone,
      password,
      role,
    });

    // Remove password from the response
    const createdUser = await User.findById(user._id).select('-password');

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      user: createdUser,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: 'Something went wrong while registering the user', error: error.message });
  }
};

// --- User Login ---
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email and password are required' });
  }

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User does not exist' });
    }

    const isPasswordValid = await user.isPasswordCorrect(password);
    if (!isPasswordValid) {
      return res.status(401).json({ success: false, message: 'Invalid user credentials' });
    }

    const accessToken = user.generateAccessToken();

    const loggedInUser = await User.findById(user._id).select('-password');

    return res.status(200).json({
      success: true,
      message: 'User logged in successfully',
      user: loggedInUser,
      accessToken,
    });

  } catch (error) {
    return res.status(500).json({ success: false, message: 'Something went wrong while logging in', error: error.message });
  }
};

export { registerUser, loginUser };