import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meal_service.dart';

class DashboardPage extends StatelessWidget {
  final void Function(int)? onSwitchTab;

  const DashboardPage({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final mealService = context.watch<MealService>();
    final entries = mealService.entries;

    return Scaffold(
      appBar: AppBar(title: const Text('NutriPal Dashboard')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/log-meal'),
        label: const Text('Log Meal'),
        icon: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(
            calories: mealService.totalCalories,
            protein: mealService.totalProtein,
            carbs: mealService.totalCarbs,
            fats: mealService.totalFats,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/create-nutrition-plan'),
                  icon: const Icon(Icons.restaurant_menu),
                  label: const Text('Nutrition Plan'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/meal-history'),
                  icon: const Icon(Icons.history),
                  label: const Text('Meal History'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Recent Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No meals yet. Start by logging breakfast, lunch, or dinner.'),
              ),
            )
          else
            ...entries.take(4).map(
              (meal) => Card(
                child: ListTile(
                  leading: const Icon(Icons.local_dining),
                  title: Text(meal.mealName),
                  subtitle: Text('${meal.mealType} • ${meal.calories} kcal'),
                  trailing: Text('P${meal.protein} C${meal.carbs} F${meal.fats}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  const _SummaryCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Calories: $calories kcal'),
            Text('Protein: $protein g'),
            Text('Carbs: $carbs g'),
            Text('Fats: $fats g'),
          ],
        ),
      ),
    );
  }
}
