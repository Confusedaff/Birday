import 'package:bday/themes/darkmode.dart';
import 'package:bday/themes/lightmode.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightmode;
  final _settingsBox = Hive.box('theme');

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;
  bool get isDarkmode => _themeData == darkmode;

  void toggleTheme() {
    if (_themeData == lightmode) {
      _themeData = darkmode;
      _saveTheme(true);
    } else {
      _themeData = lightmode;
      _saveTheme(false);
    }
    notifyListeners();
  }

  void _saveTheme(bool isDark) {
    _settingsBox.put('isDarkmode', isDark);
  }

  void _loadTheme() {
    final isDark = _settingsBox.get('isDarkmode', defaultValue: false);
    _themeData = isDark ? darkmode : lightmode;
    notifyListeners();
  }
}
