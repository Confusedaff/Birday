import 'package:hive/hive.dart';
import 'package:bday/services/logger_service.dart';
import 'package:bday/config/app_constants.dart';

/// Service for managing application settings and preferences.
///
/// This service provides a clean abstraction over Hive for storing
/// user preferences such as confetti animation settings.
///
/// It handles:
/// - Confetti animation enable/disable state
/// - Tracking the last date confetti was shown (one per day limit)
/// - Default values for new settings
///
/// Usage:
/// ```dart
/// // Initialize once at app startup
/// await SettingsService.init();
///
/// // Check if confetti is enabled
/// bool enabled = SettingsService.getConfettiEnabled();
///
/// // Disable confetti animations
/// await SettingsService.setConfettiEnabled(false);
///
/// // Check if we should play confetti today
/// if (SettingsService.shouldPlayConfettiToday()) {
///   // Play confetti animation
/// }
/// ```
class SettingsService {
  static const String _boxName = 'settingsBox';
  static const String _confettiKey = AppConstants.confettiEnabledKey;
  static const String _lastConfettiDateKey = AppConstants.lastConfettiDateKey;

  /// Initializes the settings storage.
  ///
  /// This method must be called once at application startup before any
  /// other SettingsService methods are used.
  ///
  /// Throws:
  ///   - [Exception] if initialization fails (e.g., corrupted storage)
  ///
  /// Safe to call multiple times - subsequent calls are no-ops if the
  /// box is already open.
  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName);
        AppLogger.info('Opened Hive box: $_boxName');
      }
    } catch (e) {
      AppLogger.error(
        'Failed to initialize SettingsService',
        error: e,
      );
      rethrow;
    }
  }

  /// Checks if confetti animations are enabled.
  ///
  /// Returns: true if confetti is enabled, false otherwise (default: false)
  ///
  /// Example:
  /// ```dart
  /// if (SettingsService.getConfettiEnabled()) {
  ///   // Show confetti animation
  /// }
  /// ```
  static bool getConfettiEnabled() {
    try {
      final box = Hive.box(_boxName);
      return box.get(_confettiKey, defaultValue: false);
    } catch (e) {
      AppLogger.error(
        'Failed to get confetti enabled setting',
        error: e,
      );
      return false;
    }
  }

  /// Sets the confetti animation preference.
  ///
  /// Parameters:
  ///   - value: true to enable confetti, false to disable
  ///
  /// Throws:
  ///   - Hive-specific exceptions for storage errors
  ///
  /// Example:
  /// ```dart
  /// // Disable confetti animations
  /// await SettingsService.setConfettiEnabled(false);
  /// ```
  static Future<void> setConfettiEnabled(bool value) async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_confettiKey, value);
      AppLogger.info('Confetti animations ${value ? 'enabled' : 'disabled'}');
    } catch (e) {
      AppLogger.error(
        'Failed to set confetti enabled setting',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets the last date confetti was displayed.
  ///
  /// Returns the date in ISO 8601 format (YYYY-MM-DD).
  ///
  /// Returns: The date string, or null if confetti has never been displayed
  ///
  /// Example:
  /// ```dart
  /// final lastDate = SettingsService.getLastConfettiDate();
  /// print(lastDate); // "2024-03-15"
  /// ```
  static String? getLastConfettiDate() {
    try {
      final box = Hive.box(_boxName);
      return box.get(_lastConfettiDateKey);
    } catch (e) {
      AppLogger.error(
        'Failed to get last confetti date',
        error: e,
      );
      return null;
    }
  }

  /// Records that confetti was shown today.
  ///
  /// Should be called after displaying confetti animation to prevent
  /// showing it multiple times on the same day.
  ///
  /// Parameters:
  ///   - date: The date in ISO 8601 format (YYYY-MM-DD). If not provided,
  ///     uses today's date.
  ///
  /// Throws:
  ///   - Hive-specific exceptions for storage errors
  ///
  /// Example:
  /// ```dart
  /// // Record confetti for today
  /// await SettingsService.setLastConfettiDate(
  ///   DateTime.now().toIso8601String().split('T')[0]
  /// );
  /// ```
  static Future<void> setLastConfettiDate(String date) async {
    try {
      final box = Hive.box(_boxName);
      await box.put(_lastConfettiDateKey, date);
      AppLogger.debug('Recorded last confetti date: $date');
    } catch (e) {
      AppLogger.error(
        'Failed to set last confetti date',
        error: e,
      );
      rethrow;
    }
  }

  /// Checks if confetti should be displayed today.
  ///
  /// This method ensures confetti is only shown once per day by comparing
  /// today's date with the last date confetti was shown.
  ///
  /// Returns: true if confetti hasn't been shown today, false otherwise
  ///
  /// Example:
  /// ```dart
  /// if (SettingsService.shouldPlayConfettiToday()) {
  ///   // Play confetti animation
  ///   await SettingsService.setLastConfettiDate(
  ///     DateTime.now().toIso8601String().split('T')[0]
  ///   );
  /// }
  /// ```
  static bool shouldPlayConfettiToday() {
    try {
      // Get today's date in YYYY-MM-DD format
      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastPlayed = getLastConfettiDate();

      final shouldPlay = lastPlayed != today;
      AppLogger.debug(
        'Should play confetti today: $shouldPlay (last: $lastPlayed, today: $today)',
      );

      return shouldPlay;
    } catch (e) {
      AppLogger.error(
        'Error checking if confetti should play today',
        error: e,
      );
      return false;
    }
  }
}