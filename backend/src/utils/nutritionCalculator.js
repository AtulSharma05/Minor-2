const ACTIVITY_FACTORS = {
  sedentary: 1.2,
  light: 1.375,
  moderate: 1.55,
  very_active: 1.725,
  athlete: 1.9,
};

function round(value, digits = 0) {
  const p = 10 ** digits;
  return Math.round(value * p) / p;
}

function calculateBmr({ weightKg, heightCm, age, gender }) {
  const sexConstant = gender === 'male' ? 5 : -161;
  return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + sexConstant;
}

function calculateTargets(profile) {
  const { weightKg, heightCm, age, bodyFatPercent, gender, activityLevel, goalType } = profile;

  const bmr = calculateBmr({ weightKg, heightCm, age, gender });
  const activityFactor = ACTIVITY_FACTORS[activityLevel] || ACTIVITY_FACTORS.moderate;
  const maintenanceCalories = bmr * activityFactor;

  const recompCalories = maintenanceCalories * 0.9;
  const targetCalories = goalType === 'maintenance' ? maintenanceCalories : recompCalories;

  const leanMassKg = bodyFatPercent != null
    ? weightKg * (1 - (bodyFatPercent / 100))
    : null;

  const proteinBaseKg = leanMassKg ?? weightKg;
  const proteinPerKg = goalType === 'recomp' ? 2.2 : 1.8;
  const proteinG = proteinBaseKg * proteinPerKg;

  const fatsPerKg = goalType === 'recomp' ? 0.8 : 0.9;
  const fatsG = weightKg * fatsPerKg;

  const proteinCalories = proteinG * 4;
  const fatCalories = fatsG * 9;
  const remainingCalories = Math.max(targetCalories - proteinCalories - fatCalories, 0);
  const carbsG = remainingCalories / 4;

  return {
    inputs: {
      weightKg,
      heightCm,
      age,
      bodyFatPercent,
      gender,
      activityLevel,
      goalType,
    },
    factors: {
      activityFactor,
      proteinPerKg,
      fatsPerKg,
    },
    formulas: {
      bmr: 'Mifflin-St Jeor: 10*weight + 6.25*height - 5*age + s (s=+5 male, -161 female)',
      maintenance: 'maintenanceCalories = BMR * activityFactor',
      recomp: 'recompCalories = maintenanceCalories * 0.90',
      protein: 'proteinG = (leanMass or bodyWeight) * proteinPerKg',
      fats: 'fatsG = bodyWeight * fatsPerKg',
      carbs: 'carbsG = (targetCalories - proteinCalories - fatCalories) / 4',
    },
    results: {
      bmr: round(bmr),
      maintenanceCalories: round(maintenanceCalories),
      recompCalories: round(recompCalories),
      targetCalories: round(targetCalories),
      proteinG: round(proteinG),
      carbsG: round(carbsG),
      fatsG: round(fatsG),
      proteinCalories: round(proteinCalories),
      carbCalories: round(carbsG * 4),
      fatCalories: round(fatCalories),
    },
  };
}

module.exports = { calculateTargets };
