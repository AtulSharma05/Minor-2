# Project2 - NutriPal

NutriPal is now a full-stack nutrition and food tracking app.

## Tech Stack
- Frontend: Flutter
- Backend: Node.js + Express
- Database: MongoDB + Mongoose
- Auth: JWT

## Project Structure
- frontend/
  - Flutter app with nutrition UI and API integration
- backend/
  - Express API server
  - MongoDB models for users and meals
  - JWT authentication

## Run Backend
1. cd backend
2. npm install
3. copy .env.example to .env
4. set MONGODB_URI and JWT_SECRET
5. npm run dev

## Run Frontend
1. cd frontend
2. flutter pub get
3. flutter run

## Notes
- Frontend services use backend APIs for auth, meals, and nutrition plan generation.
- No mock/local meal persistence is used for app data.
