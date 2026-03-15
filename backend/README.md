# NutriPal Backend

Node + Express + MongoDB backend for NutriPal.

## Setup
1. cd backend
2. npm install
3. copy .env.example to .env
4. npm run dev

## API Base
- http://localhost:4000/api/v1

## Endpoints
- POST /auth/register
- POST /auth/login
- GET /auth/me
- GET /meals
- POST /meals
- DELETE /meals/:id
- POST /plans/generate
