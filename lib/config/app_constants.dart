/// App-wide constants for the Birthday Reminder Application.
///
/// This file contains all configuration constants, magic numbers, and
/// string literals used throughout the application to ensure consistency
/// and maintainability.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // Application Info
  static const String appName = 'Birthday App';
  static const String appVersion = '1.0.0';

  // Notification Configuration
  static const String notificationChannelId = 'birthday_channel_id';
  static const String notificationChannelName = 'Birthday Notifications';
  static const String notificationChannelDescription =
      'Birthday Reminder Notifications';
  static const int notificationImportance = 4; // max

  // Birthday Reminder Days
  /// Days before birthday to send reminders
  static const Map<int, String> reminderMessages = {
    30: '🎉 Birthday is in 1 month!',
    15: '⏰ Birthday is in 15 days!',
    1: '🥳 Birthday is tomorrow!',
    0: '🎂 Today is their birthday! 🎉',
  };

  // Default Configuration
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;
  static const int scrollTopThreshold = 50;

  // Duration Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration confettiDuration = Duration(seconds: 5);
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration longSnackBarDuration = Duration(seconds: 3);

  // Hive Database
  static const String hiveThemeBoxName = 'theme';
  static const String hiveBirthdayBoxName = 'birthdays';
  static const String hiveSettingsBoxName = 'settings';

  // Settings Keys
  static const String confettiEnabledKey = 'confettiEnabled';
  static const String lastConfettiDateKey = 'lastConfettiDate';

  // Error Messages
  static const String errorLoadingBirthdays =
      'Failed to load birthdays. Please try again.';
  static const String errorSavingBirthday =
      'Failed to save birthday. Please try again.';
  static const String errorDeletingBirthday =
      'Failed to delete birthday. Please try again.';
  static const String errorSchedulingReminders =
      'Failed to schedule reminders. Please check permissions.';

  // Success Messages
  static const String successBirthdaySaved = 'Birthday saved successfully';
  static const String successBirthdayDeleted = 'Birthday deleted';
  static const String successReminderEnabled = 'Reminder enabled';
  static const String successReminderDisabled = 'Reminder disabled';

  // UI Text
  static const String searchPlaceholder = 'Search birthdays...';
  static const String searchHint = 'Start typing to filter birthdays by name';
  static const String noSearchResults = 'No matches found';
  static const String tryDifferentSearch = 'Try searching with a different name';
  static const String noBirthdaysYet = 'No Birthdays Yet';
  static const String addFirstBirthday = 'Add your first birthday to get started!';

  // Statistics Labels
  static const String totalLabel = 'Total';
  static const String todayLabel = 'Today';
  static const String thisWeekLabel = 'This Week';

  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minAge = 1;
  static const int maxAge = 150;

  // Theme
  static const String systemTheme = 'system';
  static const String lightTheme = 'light';
  static const String darkTheme = 'dark';
}

/// Logging levels for the application.
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Extension on LogLevel for string representation.
extension LogLevelExtension on LogLevel {
  String get label {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  String get emoji {
    switch (this) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }
}
