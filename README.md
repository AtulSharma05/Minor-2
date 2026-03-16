# NutriPal

A full-stack personal nutrition tracker. Log meals, track macros, set smart calorie targets from your body data, and monitor daily adherence — all synced to a real database.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile frontend | Flutter (Dart) |
| State management | Provider 6 |
| HTTP client | Dio 5 |
| Charts | fl_chart |
| Backend | Node.js 20 + Express 4 |
| Database | MongoDB + Mongoose 8 |
| Auth | JWT (jsonwebtoken + bcryptjs) |

---

## Project Structure

```
project2/
├── backend/                  Express API server
│   └── src/
│       ├── config/db.js      MongoDB connection
│       ├── middleware/auth.js JWT guard (requireAuth)
│       ├── models/
│       │   ├── User.js       name, email, passwordHash
│       │   ├── Meal.js       userId, mealName, mealType, calories, protein, carbs, fats
│       │   └── UserProfile.js weightKg, heightCm, age, bodyFatPercent, gender, activityLevel, goalType, aggressiveness
│       ├── routes/
│       │   ├── auth.routes.js    /api/v1/auth
│       │   ├── meals.routes.js   /api/v1/meals
│       │   ├── plans.routes.js   /api/v1/plans
│       │   └── profile.routes.js /api/v1/profile
│       ├── utils/
│       │   └── nutritionCalculator.js  Mifflin-St Jeor BMR + macro engine
│       └── server.js
└── frontend/
    └── lib/
        ├── main.dart              App entry + Provider tree
        ├── config/api_config.dart Base URL (Android emulator / web)
        ├── models/
        │   ├── meal_entry.dart
        │   ├── nutrition_stats.dart
        │   └── user_profile.dart
        ├── services/
        │   ├── api_service.dart          Dio wrapper (get/post/put/delete)
        │   ├── auth_service.dart         Login / register
        │   ├── meal_service.dart         Meal CRUD + today getters
        │   ├── profile_service.dart      Profile fetch / save
        │   └── nutrition_plan_service.dart  AI plan generation
        └── pages/
            ├── welcome_page.dart
            ├── login_page.dart
            ├── register_page.dart
            ├── onboarding_page.dart     First-login wizard
            ├── home_page.dart           Bottom nav host
            ├── dashboard_page.dart      Today summary + progress rings
            ├── analytics_page.dart      Charts + adherence
            ├── log_meal_page.dart
            ├── meal_history_page.dart
            ├── profile_page.dart        Body data + targets
            ├── create_nutrition_plan_page.dart
            └── features_page.dart
```

---

## Setup & Running

### Backend

```bash
cd backend
npm install
cp .env.example .env          # fill MONGODB_URI and JWT_SECRET
npm run dev                   # nodemon — hot reload
# or: npm start               # production
```

The server starts on `http://localhost:4000`.
`GET /health` returns `{ status: "ok" }` to confirm it is alive.

**.env values**

| Key | Example |
|---|---|
| `PORT` | `4000` |
| `MONGODB_URI` | `mongodb://127.0.0.1:27017/nutripal_db` |
| `JWT_SECRET` | any long random string |
| `JWT_EXPIRES_IN` | `7d` |

### Frontend

```bash
cd frontend
flutter pub get
flutter run                   # Android emulator, iOS simulator, or web
```

The API base URL is selected automatically in `lib/config/api_config.dart`:
- Android emulator → `http://10.0.2.2:4000/api/v1`
- Web / desktop → `http://localhost:4000/api/v1`

---

## How Everything Works

### Authentication flow

1. User taps **Create Account** on the welcome screen → `RegisterPage` calls `AuthService.register()`.
2. `AuthService` sends `POST /api/v1/auth/register` with `{ name, email, password }`.
3. Backend hashes the password with bcrypt (salt rounds = 10), saves the `User` document, and returns a signed JWT (7-day expiry) plus basic user info.
4. `ApiService` stores the token in memory and attaches it as `Authorization: Bearer <token>` on every subsequent request.
5. On login (`POST /api/v1/auth/login`) the same token is returned and stored.
6. The `requireAuth` middleware in Express decodes the JWT on every protected route and populates `req.user = { id, email }`.

### First-run onboarding

After a successful login `HomePage.initState` fetches the user's profile. If none exists it pushes `/onboarding`, a 3-step `PageView`:

- **Step 1** – body metrics (weight, height, age, optional body fat %)
- **Step 2** – gender and activity level (selectable cards)
- **Step 3** – goal preset + aggressiveness (for Fat Loss / Muscle Gain)

On "Get Started" the profile is saved via `PUT /api/v1/profile` and `/home` is pushed.

### Nutrition target calculation

All maths lives in `backend/src/utils/nutritionCalculator.js`.

**BMR** (Basal Metabolic Rate) uses the Mifflin-St Jeor equation:

```
BMR = 10 × weightKg + 6.25 × heightCm − 5 × age + s
      where s = +5 (male), −161 (female)
```

**TDEE** (Total Daily Energy Expenditure):
```
TDEE = BMR × activityFactor
```

Activity factors: Sedentary 1.2 · Light 1.375 · Moderate 1.55 · Very Active 1.725 · Athlete 1.9

**Goal presets** apply a multiplier to TDEE:

| Goal | Mild | Moderate | Aggressive |
|---|---|---|---|
| Maintenance | 1.00 | 1.00 | 1.00 |
| Recomposition | 0.90 | 0.90 | 0.90 |
| Fat Loss | 0.90 | 0.85 | 0.80 |
| Muscle Gain | 1.05 | 1.08 | 1.12 |

**Macro split** (per goal):

```
Protein  = (leanMass if bodyFat% given, else bodyWeight) × proteinPerKg
Fats     = bodyWeight × fatsPerKg
Carbs    = (targetCalories − proteinCal − fatCal) / 4
```

Protein per kg: Fat Loss 2.4 · Recomp 2.2 · Muscle Gain 2.0 · Maintenance 1.8  
Fats per kg: Fat Loss 0.7 · Recomp 0.8 · Muscle Gain 1.0 · Maintenance 0.9

The response includes `inputs`, `factors`, `formulas` (human-readable strings), and `results` — full transparency for the UI.

### Meal logging

1. User taps **+ Log Meal** → `LogMealPage` collects name, type, calories, protein, carbs, fats.
2. `MealService.addMeal()` sends `POST /api/v1/meals`.
3. Backend creates a `Meal` document with the authenticated `userId` from the JWT and returns it.
4. `MealService` re-fetches the full meal list and calls `fetchStats()`.
5. `notifyListeners()` triggers a rebuild of Dashboard and Analytics.

### Dashboard — Today summary & progress rings

`DashboardPage` reads from `MealService`:

```dart
todayEntries  // meals where createdAt.toLocal() matches today's date
todayCalories / todayProtein / todayCarbs / todayFats
```

If `ProfileService.calculations` is available it renders four circular `_ProgressRing` widgets (Kcal, Protein, Carbs, Fats) showing `current / target` with a `CircularProgressIndicator` clamped to 100 %.

### Analytics — Charts & Adherence

**Period selector** (Today / 7 / 30 / 90 days) filters `mealService.entries` locally using the device local date so UTC server timestamps are handled correctly.

**Bar chart** — builds a full list of day keys covering the whole window (including zero-calorie days) then aggregates calories per day using a `Map<String, int>`. No dependency on backend stats.

**Macro split** pie chart uses macro calories (`protein×4`, `carbs×4`, `fats×9`) divided by total macro calories to avoid exceeding 100 %.

**7-Day Adherence card** (visible only when a profile exists):
- Always covers the last 7 calendar days regardless of the selected period.
- A day is "on target" if logged calories are within ±20 % of `targetCalories`.
- Green circle ✓ = on target · Orange ✗ = off target · Grey = no data logged.
- Overall compliance percentage shown as a badge; green ≥ 70 %, orange below.

### Meal History

`MealHistoryPage` supports:
- **Search** by meal name (client-side filter)
- **Filter chips** by meal type (All / Breakfast / Lunch / Dinner / Snack)
- **Delete** with confirmation dialog → `MealService.removeMeal(id)` → `DELETE /api/v1/meals/:id`
- **Pull-to-refresh**

### AI Nutrition Plan

`FeaturesPage` → `CreateNutritionPlanPage` sends a free-text goal description to `POST /api/v1/plans/generate`. The backend returns a list of suggested meals with macro breakdowns.

---

## API Reference

All endpoints require `Authorization: Bearer <token>` unless marked public.

### Auth — `/api/v1/auth`

| Method | Path | Body | Description |
|---|---|---|---|
| POST | `/register` | `{ name, email, password }` | Create account, returns token |
| POST | `/login` | `{ email, password }` | Login, returns token |
| GET | `/me` | — | Returns current user info |

### Meals — `/api/v1/meals`

| Method | Path | Query / Body | Description |
|---|---|---|---|
| GET | `/` | — | All meals for authenticated user (newest first) |
| GET | `/stats` | `?periodDays=7` | Daily calorie chart data + period totals |
| POST | `/` | `{ mealName, mealType, calories, protein, carbs, fats }` | Log a meal |
| DELETE | `/:id` | — | Delete a meal |

### Profile — `/api/v1/profile`

| Method | Path | Body | Description |
|---|---|---|---|
| GET | `/` | — | Current profile + calculated targets |
| PUT | `/` | `{ weightKg, heightCm, age, bodyFatPercent?, gender, activityLevel, goalType, aggressiveness }` | Upsert profile, returns profile + calculations |

### Plans — `/api/v1/plans`

| Method | Path | Body | Description |
|---|---|---|---|
| POST | `/generate` | `{ goal }` | Returns AI-suggested meal plan |

---

## Data Models

### User
```js
{ name, email, passwordHash, createdAt, updatedAt }
```

### Meal
```js
{ userId (ObjectId), mealName, mealType (Breakfast|Lunch|Dinner|Snack),
  calories, protein, carbs, fats, createdAt, updatedAt }
```

### UserProfile
```js
{ userId (ObjectId, unique), weightKg, heightCm, age,
  bodyFatPercent (nullable), gender (male|female),
  activityLevel (sedentary|light|moderate|very_active|athlete),
  goalType (maintenance|recomp|fat_loss|muscle_gain),
  aggressiveness (1–3), createdAt, updatedAt }
```

---

## Flutter Provider Tree

```
ApiService               (plain Provider — Dio wrapper, holds JWT token)
  └── AuthService        (plain Provider — login/register/logout)
  └── MealService        (ChangeNotifier — meal list, today getters, stats)
  └── ProfileService     (ChangeNotifier — profile + macro calculations)
  └── NutritionPlanService (plain Provider — plan generation)
```

All services receive `ApiService` through `context.read<ApiService>()` at creation time. No service holds any UI reference — they only call `notifyListeners()`.

---

## Security Notes

- Passwords are hashed with bcrypt (cost factor 10) — never stored in plain text.
- JWT is signed with `JWT_SECRET` from environment — never hardcoded in production.
- Every data-mutating endpoint verifies the JWT and uses `req.user.id` from the decoded payload — users can only access their own documents.
- MongoDB queries for aggregations cast the userId string to `ObjectId` explicitly to prevent type mismatch bypasses.
- `.env` is git-ignored; `.env.example` ships with placeholder values only.

