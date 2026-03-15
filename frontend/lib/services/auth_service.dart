import 'api_service.dart';

class AuthService {
  AuthService(this._apiService);

  final ApiService _apiService;
  String? _email;

  bool get isLoggedIn => _email != null;
  String get userEmail => _email ?? 'guest@nutripal.app';

  Future<bool> login({required String email, required String password}) async {
    if (email.isEmpty || password.length < 6) return false;
    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = (data['token'] ?? '').toString();
      final user = (data['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      if (token.isEmpty) return false;
      _apiService.setToken(token);
      _email = (user['email'] ?? email).toString();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty || email.isEmpty || password.length < 6) return false;
    try {
      final response = await _apiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = (data['token'] ?? '').toString();
      final user = (data['user'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      if (token.isEmpty) return false;
      _apiService.setToken(token);
      _email = (user['email'] ?? email).toString();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _apiService.setToken(null);
    _email = null;
  }
}
