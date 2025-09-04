import 'package:hive/hive.dart';

class SettingsService {
  static const String _boxName = "settingsBox";
  static const String _confettiKey = "confettiEnabled";
  static const String _lastConfettiDateKey = "lastConfettiDate";
  
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }
  
  static bool getConfettiEnabled() {
    final box = Hive.box(_boxName);
    return box.get(_confettiKey, defaultValue: false); // Changed default to true
  }
  
  static Future<void> setConfettiEnabled(bool value) async {
    final box = Hive.box(_boxName);
    await box.put(_confettiKey, value);
  }
  
  // New methods for tracking confetti date
  static String? getLastConfettiDate() {
    final box = Hive.box(_boxName);
    return box.get(_lastConfettiDateKey);
  }
  
  static Future<void> setLastConfettiDate(String date) async {
    final box = Hive.box(_boxName);
    await box.put(_lastConfettiDateKey, date);
  }
  
  static bool shouldPlayConfettiToday() {
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    final lastPlayed = getLastConfettiDate();
    return lastPlayed != today;
  }
}