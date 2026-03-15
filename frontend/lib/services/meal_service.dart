import 'package:flutter/foundation.dart';
import '../models/meal_entry.dart';
import 'api_service.dart';

class MealService extends ChangeNotifier {
  MealService(this._apiService);

  final ApiService _apiService;
  final List<MealEntry> _entries = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<MealEntry> get entries => List<MealEntry>.from(_entries)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> fetchMeals() async {
    if (_apiService.token == null) {
      _entries.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/meals');
      final data = response.data as Map<String, dynamic>;
      final meals = (data['meals'] as List<dynamic>? ?? [])
          .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _entries
        ..clear()
        ..addAll(meals);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMeal(MealEntry meal) async {
    await _apiService.post('/meals', meal.toCreatePayload());
    await fetchMeals();
  }

  Future<void> removeMeal(String id) async {
    await _apiService.delete('/meals/$id');
    await fetchMeals();
  }

  int get totalCalories => _entries.fold(0, (sum, m) => sum + m.calories);
  int get totalProtein => _entries.fold(0, (sum, m) => sum + m.protein);
  int get totalCarbs => _entries.fold(0, (sum, m) => sum + m.carbs);
  int get totalFats => _entries.fold(0, (sum, m) => sum + m.fats);
}
