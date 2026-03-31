const express = require('express');
const Food = require('../models/Food');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

router.get('/', requireAuth, asyncHandler(async (req, res) => {
  const { category, search, limit = 50 } = req.query;
  const query = {};

  if (category) query.category = category;
  if (search) query.name = { $regex: search, $options: 'i' };

  const foods = await Food.find(query).limit(Math.max(1, Math.min(Number(limit), 200))).sort({ name: 1 });
  return res.json({ foods, count: foods.length });
}));

router.post('/', requireAuth, asyncHandler(async (req, res) => {
  const food = await Food.create(req.body);
  return res.status(201).json({ food });
}));

module.exports = router;
