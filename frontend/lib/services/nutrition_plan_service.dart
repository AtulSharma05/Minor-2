import 'api_service.dart';

class NutritionPlanService {
  NutritionPlanService(this._apiService);

  final ApiService _apiService;

  Future<List<String>> generatePlan({
    required String goal,
    required int mealsPerDay,
    required bool vegetarian,
  }) async {
    final response = await _apiService.post('/plans/generate', {
      'goal': goal,
      'mealsPerDay': mealsPerDay,
      'vegetarian': vegetarian,
    });
    final data = response.data as Map<String, dynamic>;
    final plan = (data['plan'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    return plan;
  }
}
