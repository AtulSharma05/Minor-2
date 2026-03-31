const mongoose = require('mongoose');

const mealPlanSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    planName: { type: String, required: true, trim: true },
    startDate: { type: Date, required: true },
    duration: { type: Number, enum: [7], required: true, default: 7 },
    meals: [
      {
        date: { type: Date, required: true },
        mealType: { type: String, enum: ['Breakfast', 'Lunch', 'Dinner', 'Snack'], required: true },
        foodItems: [
          {
            foodId: { type: mongoose.Schema.Types.ObjectId, ref: 'Food' },
            foodName: { type: String, required: true },
            servings: { type: Number, required: true, min: 0.1 },
            calories: { type: Number, required: true, min: 0 },
            protein: { type: Number, required: true, min: 0 },
            carbs: { type: Number, required: true, min: 0 },
            fats: { type: Number, required: true, min: 0 },
          },
        ],
        totals: {
          calories: { type: Number, required: true, min: 0 },
          protein: { type: Number, required: true, min: 0 },
          carbs: { type: Number, required: true, min: 0 },
          fats: { type: Number, required: true, min: 0 },
        },
      },
    ],
    targets: {
      calories: { type: Number, required: true, min: 0 },
      protein: { type: Number, required: true, min: 0 },
      carbs: { type: Number, required: true, min: 0 },
      fats: { type: Number, required: true, min: 0 },
    },
    planTotals: {
      calories: { type: Number, required: true, min: 0 },
      protein: { type: Number, required: true, min: 0 },
      carbs: { type: Number, required: true, min: 0 },
      fats: { type: Number, required: true, min: 0 },
    },
    constraints: {
      vegetarian: { type: Boolean, default: false },
      vegan: { type: Boolean, default: false },
      dairyFree: { type: Boolean, default: false },
      glutenFree: { type: Boolean, default: false },
      excludedFoods: [{ type: String }],
    },
    status: { type: String, enum: ['draft', 'active', 'completed'], default: 'active' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('MealPlan', mealPlanSchema);
