// backend/src/controllers/service.controller.js

import { Service } from '../models/service.model.js';

const createService = async (req, res) => {
  try {
    const { name, icon } = req.body;
    if (!name || !icon) {
      return res.status(400).json({ success: false, message: 'Name and icon are required' });
    }

    const existingService = await Service.findOne({ name });
    if (existingService) {
        return res.status(409).json({ success: false, message: 'Service with this name already exists' });
    }

    const service = await Service.create({ name, icon });
    return res.status(201).json({ success: true, data: service });
  } catch (error) {
    console.error("Error creating service:", error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

const getAllServices = async (req, res) => {
    try {
        const services = await Service.find({});
        return res.status(200).json({ success: true, data: services });
    } catch (error) {
        console.error("Error fetching services:", error);
        return res.status(500).json({ success: false, message: 'Internal Server Error' });
    }
};

export { createService, getAllServices };