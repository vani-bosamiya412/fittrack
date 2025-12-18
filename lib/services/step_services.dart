import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepService {
  static const MethodChannel _channel =
  MethodChannel("fittrack/step_service");

  static const String _stepKey = "today_steps";
  static const String _dateKey = "step_date";

  /// Public API used by UI
  static Future<int> syncTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();

    final String today =
    DateTime.now().toIso8601String().substring(0, 10);

    final String? savedDate = prefs.getString(_dateKey);

    // Reset cache if date changed
    if (savedDate != today) {
      await prefs.setInt(_stepKey, 0);
      await prefs.setString(_dateKey, today);
    }

    final int googleFitSteps =
        await _channel.invokeMethod<int>("getTodaySteps") ?? 0;

    // Google Fit is always trusted
    await prefs.setInt(_stepKey, googleFitSteps);

    return googleFitSteps;
  }

  static Future<int> getCachedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_stepKey) ?? 0;
  }
}