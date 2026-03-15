import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/meal_service.dart';

class MealHistoryPage extends StatefulWidget {
  const MealHistoryPage({super.key});

  @override
  State<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealService>().fetchMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealService = context.watch<MealService>();
    final entries = mealService.entries;

    return Scaffold(
      appBar: AppBar(title: const Text('Meal History')),
      body: mealService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : entries.isEmpty
              ? const Center(child: Text('No meals logged yet.'))
              : RefreshIndicator(
                  onRefresh: () => context.read<MealService>().fetchMeals(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final meal = entries[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.local_dining),
                          title: Text(meal.mealName),
                          subtitle: Text(
                            '${meal.mealType} • ${DateFormat('MMM d, h:mm a').format(meal.createdAt)}',
                          ),
                          trailing: Text('${meal.calories} kcal'),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
