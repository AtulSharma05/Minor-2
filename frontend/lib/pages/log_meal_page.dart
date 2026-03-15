import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_entry.dart';
import '../services/meal_service.dart';

class LogMealPage extends StatefulWidget {
  const LogMealPage({super.key});

  @override
  State<LogMealPage> createState() => _LogMealPageState();
}

class _LogMealPageState extends State<LogMealPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fats = TextEditingController();
  String _mealType = 'Breakfast';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _cal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fats.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final meal = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mealName: _name.text.trim(),
      mealType: _mealType,
      calories: int.parse(_cal.text.trim()),
      protein: int.parse(_protein.text.trim()),
      carbs: int.parse(_carbs.text.trim()),
      fats: int.parse(_fats.text.trim()),
      createdAt: DateTime.now(),
    );

    try {
      await context.read<MealService>().addMeal(meal);
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Meal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Meal Name'),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mealType,
              items: const ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _mealType = v ?? 'Breakfast'),
              decoration: const InputDecoration(labelText: 'Meal Type'),
            ),
            const SizedBox(height: 12),
            _numField(_cal, 'Calories (kcal)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numField(_protein, 'Protein (g)')),
                const SizedBox(width: 8),
                Expanded(child: _numField(_carbs, 'Carbs (g)')),
                const SizedBox(width: 8),
                Expanded(child: _numField(_fats, 'Fats (g)')),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_saving ? 'Saving...' : 'Save Meal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return TextFormField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (v) => (v == null || int.tryParse(v) == null) ? 'Number required' : null,
    );
  }
}
