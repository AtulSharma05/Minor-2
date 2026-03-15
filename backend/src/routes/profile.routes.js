const express = require('express');
const mongoose = require('mongoose');
const { requireAuth } = require('../middleware/auth');
const UserProfile = require('../models/UserProfile');
const { calculateTargets } = require('../utils/nutritionCalculator');

const router = express.Router();

function userObjectId(userId) {
  return new mongoose.Types.ObjectId(userId);
}

router.get('/', requireAuth, async (req, res) => {
  const profile = await UserProfile.findOne({ userId: userObjectId(req.user.id) });

  if (!profile) {
    return res.json({ profile: null, calculations: null });
  }

  const calculations = calculateTargets(profile.toObject());
  return res.json({ profile, calculations });
});

router.put('/', requireAuth, async (req, res) => {
  const payload = {
    weightKg: req.body.weightKg,
    heightCm: req.body.heightCm,
    age: req.body.age,
    bodyFatPercent: req.body.bodyFatPercent ?? null,
    gender: req.body.gender,
    activityLevel: req.body.activityLevel,
    goalType: req.body.goalType ?? 'recomp',
  };

  const profile = await UserProfile.findOneAndUpdate(
    { userId: userObjectId(req.user.id) },
    { $set: payload, $setOnInsert: { userId: userObjectId(req.user.id) } },
    { new: true, upsert: true, runValidators: true }
  );

  const calculations = calculateTargets(profile.toObject());
  return res.json({ profile, calculations });
});

module.exports = router;
