const express = require('express');
const Meal = require('../models/Meal');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.get('/', requireAuth, async (req, res) => {
  const meals = await Meal.find({ userId: req.user.id }).sort({ createdAt: -1 });
  return res.json({ meals });
});

router.post('/', requireAuth, async (req, res) => {
  const { mealName, mealType, calories, protein, carbs, fats } = req.body;

  if (!mealName || !mealType) {
    return res.status(400).json({ message: 'mealName and mealType are required' });
  }

  const meal = await Meal.create({
    userId: req.user.id,
    mealName,
    mealType,
    calories,
    protein,
    carbs,
    fats,
  });

  return res.status(201).json({ meal });
});

router.delete('/:id', requireAuth, async (req, res) => {
  const { id } = req.params;
  const deleted = await Meal.findOneAndDelete({ _id: id, userId: req.user.id });

  if (!deleted) {
    return res.status(404).json({ message: 'Meal not found' });
  }

  return res.json({ message: 'Meal deleted' });
});

module.exports = router;
