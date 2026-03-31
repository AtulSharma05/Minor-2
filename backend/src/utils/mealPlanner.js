const Food = require('../models/Food');
const { calculateTargets } = require('./nutritionCalculator');

const MEAL_SPLIT = [
  { mealType: 'Breakfast', ratio: 0.25 },
  { mealType: 'Lunch', ratio: 0.35 },
  { mealType: 'Dinner', ratio: 0.3 },
  { mealType: 'Snack', ratio: 0.1 },
];
const PLAN_DAYS = 7;

function round(value, digits = 1) {
  const p = 10 ** digits;
  return Math.round(value * p) / p;
}

async function loadCandidateFoods(constraints) {
  const foods = await Food.find({}).lean();

  return foods.filter((food) => {
    const tags = Array.isArray(food.tags) ? food.tags : [];

    if (constraints.excludedFoods?.length && constraints.excludedFoods.includes(food.name)) {
      return false;
    }
    if (constraints.vegan && !tags.includes('vegan')) {
      return false;
    }
    if (constraints.vegetarian && !constraints.vegan && !tags.includes('vegetarian') && !tags.includes('vegan')) {
      return false;
    }
    if (constraints.glutenFree && !tags.includes('gluten-free')) {
      return false;
    }
    if (constraints.dairyFree && !tags.includes('dairy-free')) {
      return false;
    }
    if (constraints.indianOnly && !tags.includes('indian')) {
      return false;
    }

    return true;
  });
}

function pickFoodsForMeal(foods, targetCalories, mealType, usedFoodNames) {
  const preferredCategoryByMeal = {
    Breakfast: ['grains', 'fruits', 'dairy', 'protein'],
    Lunch: ['protein', 'grains', 'vegetables', 'healthy_fats'],
    Dinner: ['protein', 'vegetables', 'grains', 'healthy_fats'],
    Snack: ['fruits', 'dairy', 'healthy_fats', 'protein'],
  };

  const categories = preferredCategoryByMeal[mealType] || ['other'];
  const selected = [];
  let calories = 0;
  let protein = 0;
  let carbs = 0;
  let fats = 0;

  for (const category of categories) {
    const pool = foods.filter(
      (f) =>
        f.category === category &&
        !usedFoodNames.has(f.name) &&
        Array.isArray(f.mealSlots) &&
        f.mealSlots.includes(mealType)
    );
    if (!pool.length) continue;

    const food = pool[Math.floor(Math.random() * pool.length)];
    const remaining = Math.max(targetCalories - calories, targetCalories * 0.35);
    const grams = Math.max(60, Math.min(220, (remaining / Math.max(food.caloriesPer100g, 1)) * 100));

    const entry = {
      foodId: food._id,
      foodName: food.name,
      servings: round(grams / Math.max(food.servingSizeG || 100, 1), 2),
      calories: round((food.caloriesPer100g * grams) / 100, 0),
      protein: round((food.proteinG * grams) / 100, 1),
      carbs: round((food.carbsG * grams) / 100, 1),
      fats: round((food.fatsG * grams) / 100, 1),
    };

    selected.push(entry);
    usedFoodNames.add(food.name);

    calories += entry.calories;
    protein += entry.protein;
    carbs += entry.carbs;
    fats += entry.fats;

    if (calories >= targetCalories * 0.92) break;
    if (selected.length >= 3) break;
  }

  return {
    foodItems: selected,
    totals: {
      calories: round(calories, 0),
      protein: round(protein, 1),
      carbs: round(carbs, 1),
      fats: round(fats, 1),
    },
  };
}

function buildDayDate(startDate, dayOffset) {
  const d = new Date(startDate);
  d.setDate(d.getDate() + dayOffset);
  return d;
}

async function generateMealPlan({
  userProfile,
  constraints,
}) {
  const calculation = calculateTargets(userProfile);
  const targets = {
    calories: calculation.results.targetCalories,
    protein: calculation.results.proteinG,
    carbs: calculation.results.carbsG,
    fats: calculation.results.fatsG,
  };

  const foods = await loadCandidateFoods(constraints);

  if (!foods.length) {
    return {
      error: 'No foods available for selected constraints. Add foods or relax filters.',
      targets,
    };
  }

  const startDate = new Date();
  startDate.setHours(0, 0, 0, 0);

  const meals = [];
  const planTotals = { calories: 0, protein: 0, carbs: 0, fats: 0 };

  for (let day = 0; day < PLAN_DAYS; day++) {
    const usedFoodNames = new Set();

    for (const slot of MEAL_SPLIT) {
      const meal = pickFoodsForMeal(foods, targets.calories * slot.ratio, slot.mealType, usedFoodNames);

      meals.push({
        date: buildDayDate(startDate, day),
        mealType: slot.mealType,
        foodItems: meal.foodItems,
        totals: meal.totals,
      });

      planTotals.calories += meal.totals.calories;
      planTotals.protein += meal.totals.protein;
      planTotals.carbs += meal.totals.carbs;
      planTotals.fats += meal.totals.fats;
    }
  }

  return {
    meals,
    targets,
    planTotals: {
      calories: round(planTotals.calories, 0),
      protein: round(planTotals.protein, 1),
      carbs: round(planTotals.carbs, 1),
      fats: round(planTotals.fats, 1),
    },
  };
}

module.exports = {
  generateMealPlan,
};
