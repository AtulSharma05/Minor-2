import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/meal_service.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mealService = context.watch<MealService>();
    final total = mealService.totalCalories == 0 ? 1 : mealService.totalCalories;

    final proteinCal = mealService.totalProtein * 4;
    final carbsCal = mealService.totalCarbs * 4;
    final fatsCal = mealService.totalFats * 9;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Macro Split', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(value: proteinCal.toDouble(), title: 'Protein', color: Colors.green),
                          PieChartSectionData(value: carbsCal.toDouble(), title: 'Carbs', color: Colors.orange),
                          PieChartSectionData(value: fatsCal.toDouble(), title: 'Fats', color: Colors.pink),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Total Calories: ${mealService.totalCalories} kcal'),
                  Text('Protein calories: ${((proteinCal / total) * 100).toStringAsFixed(1)}%'),
                  Text('Carb calories: ${((carbsCal / total) * 100).toStringAsFixed(1)}%'),
                  Text('Fat calories: ${((fatsCal / total) * 100).toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
