import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/nutrition_plan_service.dart';

class CreateNutritionPlanPage extends StatefulWidget {
  const CreateNutritionPlanPage({super.key});

  @override
  State<CreateNutritionPlanPage> createState() => _CreateNutritionPlanPageState();
}

class _CreateNutritionPlanPageState extends State<CreateNutritionPlanPage> {
  String _goal = 'weight_loss';
  int _mealsPerDay = 4;
  bool _vegetarian = false;
  bool _loading = false;
  List<String> _plan = [];

  Future<void> _generate() async {
    setState(() => _loading = true);
    final data = await context.read<NutritionPlanService>().generatePlan(
          goal: _goal,
          mealsPerDay: _mealsPerDay,
          vegetarian: _vegetarian,
        );
    if (!mounted) return;
    setState(() {
      _plan = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Nutrition Plan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Goal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'weight_loss', label: Text('Weight Loss')),
              ButtonSegment(value: 'maintenance', label: Text('Maintenance')),
              ButtonSegment(value: 'muscle_gain', label: Text('Muscle Gain')),
            ],
            selected: {_goal},
            onSelectionChanged: (v) => setState(() => _goal = v.first),
          ),
          const SizedBox(height: 20),
          Text('Meals per day: $_mealsPerDay'),
          Slider(
            value: _mealsPerDay.toDouble(),
            min: 3,
            max: 6,
            divisions: 3,
            onChanged: (v) => setState(() => _mealsPerDay = v.toInt()),
          ),
          SwitchListTile(
            title: const Text('Vegetarian options'),
            value: _vegetarian,
            onChanged: (v) => setState(() => _vegetarian = v),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loading ? null : _generate,
            icon: const Icon(Icons.auto_awesome),
            label: Text(_loading ? 'Generating...' : 'Generate Plan'),
          ),
          const SizedBox(height: 18),
          if (_plan.isNotEmpty) ...[
            const Text('Suggested Daily Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ..._plan.map((item) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.restaurant),
                    title: Text(item),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
