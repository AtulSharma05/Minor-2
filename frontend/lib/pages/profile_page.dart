import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _bodyFatController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';
  String _goalType = 'recomp';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileService = context.read<ProfileService>();
      await profileService.fetchProfile();
      final profile = profileService.profile;
      if (profile == null || !mounted) return;
      setState(() {
        _weightController.text = profile.weightKg.toStringAsFixed(1);
        _heightController.text = profile.heightCm.toStringAsFixed(1);
        _ageController.text = profile.age.toString();
        _bodyFatController.text = profile.bodyFatPercent?.toStringAsFixed(1) ?? '';
        _gender = profile.gender;
        _activityLevel = profile.activityLevel;
        _goalType = profile.goalType;
      });
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      weightKg: double.parse(_weightController.text.trim()),
      heightCm: double.parse(_heightController.text.trim()),
      age: int.parse(_ageController.text.trim()),
      bodyFatPercent: _bodyFatController.text.trim().isEmpty
          ? null
          : double.parse(_bodyFatController.text.trim()),
      gender: _gender,
      activityLevel: _activityLevel,
      goalType: _goalType,
    );

    await context.read<ProfileService>().saveProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile and nutrition targets updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final profileService = context.watch<ProfileService>();
    final calculations = profileService.calculations;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
            const SizedBox(height: 10),
            Text(auth.userEmail, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _numberField(_weightController, 'Weight (kg)')),
                      const SizedBox(width: 10),
                      Expanded(child: _numberField(_heightController, 'Height (cm)')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _numberField(_ageController, 'Age')),
                      const SizedBox(width: 10),
                      Expanded(child: _numberField(_bodyFatController, 'Body fat % (opt)')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (v) => setState(() => _gender = v ?? 'male'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _activityLevel,
                    decoration: const InputDecoration(labelText: 'Activity level'),
                    items: const [
                      DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
                      DropdownMenuItem(value: 'light', child: Text('Light')),
                      DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                      DropdownMenuItem(value: 'very_active', child: Text('Very active')),
                      DropdownMenuItem(value: 'athlete', child: Text('Athlete')),
                    ],
                    onChanged: (v) => setState(() => _activityLevel = v ?? 'moderate'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _goalType,
                    decoration: const InputDecoration(labelText: 'Goal'),
                    items: const [
                      DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                      DropdownMenuItem(value: 'recomp', child: Text('Recomposition')),
                    ],
                    onChanged: (v) => setState(() => _goalType = v ?? 'recomp'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: profileService.isLoading ? null : _saveProfile,
                    icon: const Icon(Icons.calculate),
                    label: Text(profileService.isLoading ? 'Calculating...' : 'Save & Calculate Targets'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (calculations != null) ...[
              const Text('Transparent Calculations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BMR (Mifflin-St Jeor): ${calculations.bmr} kcal'),
                      Text('Maintenance Calories: ${calculations.maintenanceCalories} kcal'),
                      Text('Recomp Calories: ${calculations.recompCalories} kcal'),
                      Text('Target Calories: ${calculations.targetCalories} kcal'),
                      const SizedBox(height: 8),
                      Text('Protein: ${calculations.proteinG} g (${calculations.proteinCalories} kcal)'),
                      Text('Carbs: ${calculations.carbsG} g (${calculations.carbCalories} kcal)'),
                      Text('Fats: ${calculations.fatsG} g (${calculations.fatCalories} kcal)'),
                      const SizedBox(height: 10),
                      const Text('Formulas', style: TextStyle(fontWeight: FontWeight.w600)),
                      ...calculations.formulas.entries.map((e) => Text('- ${e.value}')),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final raw = value?.trim() ?? '';
        if (label.contains('opt') && raw.isEmpty) return null;
        if (raw.isEmpty) return 'Required';
        if (double.tryParse(raw) == null) return 'Invalid number';
        return null;
      },
    );
  }
}
