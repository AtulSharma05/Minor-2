import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/nutrition_plan_service.dart';

class CreateNutritionPlanPage extends StatefulWidget {
  const CreateNutritionPlanPage({super.key});

  @override
  State<CreateNutritionPlanPage> createState() => _CreateNutritionPlanPageState();
}

class _CreateNutritionPlanPageState extends State<CreateNutritionPlanPage> {
  bool _vegetarian = false;
  bool _vegan = false;
  bool _dairyFree = false;
  bool _glutenFree = false;
  bool _indianOnly = true;
  bool _loading = false;
  String? _error;
  GeneratedPlan? _plan;

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await context.read<NutritionPlanService>().generatePlan(
            vegetarian: _vegetarian,
            vegan: _vegan,
            dairyFree: _dairyFree,
            glutenFree: _glutenFree,
            indianOnly: _indianOnly,
          );

      if (!mounted) return;
      setState(() {
        _plan = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Map<DateTime, List<PlannedMeal>> _groupMealsByDay(List<PlannedMeal> meals) {
    final grouped = <DateTime, List<PlannedMeal>>{};
    for (final meal in meals) {
      final key = DateTime(meal.date.year, meal.date.month, meal.date.day);
      grouped.putIfAbsent(key, () => []).add(meal);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Nutrition Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Target source: profile calculations', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Calories and macros are taken from your profile goal and activity settings.',
          ),
          const SizedBox(height: 20),
          const Text('Plan duration: 7 days', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Vegetarian options'),
            value: _vegetarian,
            onChanged: (v) => setState(() => _vegetarian = v),
          ),
          SwitchListTile(
            title: const Text('Vegan only'),
            value: _vegan,
            onChanged: (v) => setState(() => _vegan = v),
          ),
          SwitchListTile(
            title: const Text('Dairy free'),
            value: _dairyFree,
            onChanged: (v) => setState(() => _dairyFree = v),
          ),
          SwitchListTile(
            title: const Text('Gluten free'),
            value: _glutenFree,
            onChanged: (v) => setState(() => _glutenFree = v),
          ),
          SwitchListTile(
            title: const Text('Indian meals only'),
            value: _indianOnly,
            onChanged: (v) => setState(() => _indianOnly = v),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loading ? null : _generate,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_loading ? 'Generating...' : 'Generate Plan'),
          ),
          const SizedBox(height: 18),
          if (_plan != null) ...[
            Text(_plan!.planName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Daily targets: ${_plan!.targetCalories.toStringAsFixed(0)} kcal | '
              'P ${_plan!.targetProtein.toStringAsFixed(0)}g | '
              'C ${_plan!.targetCarbs.toStringAsFixed(0)}g | '
              'F ${_plan!.targetFats.toStringAsFixed(0)}g',
            ),
            const SizedBox(height: 8),
            ..._groupMealsByDay(_plan!.meals).entries.map(
                  (entry) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.toIso8601String().split('T').first,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          ...entry.value.map(
                            (meal) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${meal.mealType} - ${meal.calories.toStringAsFixed(0)} kcal',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  ...meal.items.map((item) => Text(
                                        '- ${item.foodName} (${item.servings.toStringAsFixed(1)} serving)',
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
