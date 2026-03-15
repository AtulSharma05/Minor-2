import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'services/meal_service.dart';
import 'services/nutrition_plan_service.dart';
import 'services/profile_service.dart';
import 'theme/app_theme.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/log_meal_page.dart';
import 'pages/meal_history_page.dart';
import 'pages/create_nutrition_plan_page.dart';
import 'pages/onboarding_page.dart';

void main() {
  runApp(const NutriPalApp());
}

class NutriPalApp extends StatelessWidget {
  const NutriPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<AuthService>(
          create: (context) => AuthService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<MealService>(
          create: (context) => MealService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<ProfileService>(
          create: (context) => ProfileService(context.read<ApiService>()),
        ),
        Provider<NutritionPlanService>(
          create: (context) => NutritionPlanService(context.read<ApiService>()),
        ),
      ],
      child: MaterialApp(
        title: 'NutriPal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (_) => const WelcomePage(),
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home': (_) => const HomePage(),
          '/log-meal': (_) => const LogMealPage(),
          '/meal-history': (_) => const MealHistoryPage(),
          '/create-nutrition-plan': (_) => const CreateNutritionPlanPage(),
          '/onboarding': (_) => const OnboardingPage(),
        },
      ),
    );
  }
}
