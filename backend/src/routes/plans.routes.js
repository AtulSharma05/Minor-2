const express = require('express');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.post('/generate', requireAuth, async (req, res) => {
  const { goal = 'maintenance', mealsPerDay = 4, vegetarian = false } = req.body;

  const base = vegetarian
    ? ['Oats + berries', 'Chickpea salad', 'Greek yogurt + nuts', 'Tofu stir fry']
    : ['Egg + toast', 'Chicken rice bowl', 'Yogurt + banana', 'Salmon + veggies'];

  const plan = Array.from({ length: mealsPerDay }, (_, i) => {
    return `Meal ${i + 1}: ${base[i % base.length]} (${String(goal).replace(/_/g, ' ')})`;
  });

  return res.json({ plan });
});

module.exports = router;
