import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'hive.g.dart';

/// Model representing a birthday entry in the application.
///
/// This is a Hive-managed object that persists birthday data to the device's
/// local database. It provides computed properties for age calculation,
/// next birthday calculation, and other birthday-related utilities.
///
/// Fields:
///   - name: The person's name (required)
///   - birthDate: Their birth date (required)
///   - alarmDate: Custom alarm date (deprecated, kept for compatibility)
///   - alarmTimeHour: Hour component of the reminder time (as string)
///   - alarmTimeMinute: Minute component of the reminder time (as string)
///   - alarmId: Identifier for the alarm/reminder (deprecated)
///   - isReminderEnabled: Whether reminders are enabled for this birthday
///   - profileImagePath: Path to the person's profile picture (optional)
///
/// Usage:
/// ```dart
/// final birthday = Birthday(
///   name: 'John Doe',
///   birthDate: DateTime(1990, 3, 15),
///   isReminderEnabled: true,
/// );
///
/// // Access computed properties
/// print(birthday.age); // Current age
/// print(birthday.daysUntilBirthday); // Days until next birthday
/// print(birthday.isBirthdayToday); // Is it their birthday today?
/// ```
@HiveType(typeId: 0)
class Birthday extends HiveObject {
  /// The person's name.
  @HiveField(0)
  String name;

  /// The person's birth date.
  @HiveField(1)
  DateTime birthDate;

  /// Custom alarm date (deprecated).
  ///
  /// Kept for backward compatibility with older versions.
  /// Use [alarmTimeHour] and [alarmTimeMinute] instead.
  @HiveField(2)
  DateTime? alarmDate;

  /// Hour component of the reminder time (stored as string).
  @HiveField(3)
  String? alarmTimeHour;

  /// Minute component of the reminder time (stored as string).
  @HiveField(4)
  String? alarmTimeMinute;

  /// Identifier for the alarm/reminder (deprecated).
  ///
  /// Kept for backward compatibility. Modern reminders use
  /// the BirthdayReminder service.
  @HiveField(5)
  String? alarmId;

  /// Whether reminders are enabled for this birthday.
  ///
  /// When true, notifications will be sent for this birthday.
  /// When false, no notifications will be scheduled.
  @HiveField(6, defaultValue: false)
  bool isReminderEnabled;

  /// Path to the person's profile picture.
  ///
  /// Can be either a local file path or null if no image is set.
  @HiveField(7)
  String? profileImagePath;

  /// Creates a new Birthday instance.
  ///
  /// Parameters:
  ///   - name: The person's name (required)
  ///   - birthDate: Their birth date (required)
  ///   - alarmDate: Custom alarm date (optional, deprecated)
  ///   - alarmTimeHour: Hour of reminder (optional)
  ///   - alarmTimeMinute: Minute of reminder (optional)
  ///   - alarmId: Alarm identifier (optional, deprecated)
  ///   - isReminderEnabled: Enable reminders (default: false)
  ///   - profileImagePath: Path to profile picture (optional)
  Birthday({
    required this.name,
    required this.birthDate,
    this.alarmDate,
    this.alarmTimeHour,
    this.alarmTimeMinute,
    this.alarmId,
    this.isReminderEnabled = false,
    this.profileImagePath,
  });

  /// Gets the reminder time as a TimeOfDay object.
  ///
  /// Converts the stored hour and minute strings to a TimeOfDay for use in UI.
  /// Returns null if either hour or minute is not set.
  ///
  /// Returns: A [TimeOfDay] representing the alarm time, or null
  TimeOfDay? get alarmTime {
    if (alarmTimeHour != null && alarmTimeMinute != null) {
      return TimeOfDay(
        hour: int.parse(alarmTimeHour!),
        minute: int.parse(alarmTimeMinute!),
      );
    }
    return null;
  }

  /// Sets the reminder time from a TimeOfDay object.
  ///
  /// Converts the TimeOfDay to strings for storage in Hive.
  ///
  /// Parameters:
  ///   - time: The [TimeOfDay] to set as the alarm time
  void setAlarmTime(TimeOfDay time) {
    alarmTimeHour = time.hour.toString();
    alarmTimeMinute = time.minute.toString();
  }

  /// Calculates the current age based on birth date.
  ///
  /// Returns the number of complete years since the birth date.
  /// Takes into account whether the birthday has occurred this year.
  ///
  /// Returns: The person's current age in years
  ///
  /// Example:
  /// ```dart
  /// final birthday = Birthday(name: 'John', birthDate: DateTime(1990, 3, 15));
  /// print(birthday.age); // 34 (if current date is after March 15)
  /// ```
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Calculates the number of days until the next birthday.
  ///
  /// Returns 0 if today is their birthday.
  ///
  /// Returns: Number of days until the next birthday
  ///
  /// Example:
  /// ```dart
  /// final birthday = Birthday(name: 'John', birthDate: DateTime(1990, 3, 15));
  /// print(birthday.daysUntilBirthday); // e.g., 45
  /// ```
  int get daysUntilBirthday {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, birthDate.month, birthDate.day);
    final nextYear = DateTime(now.year + 1, birthDate.month, birthDate.day);

    if (thisYear.isAfter(now) || thisYear.isAtSameMomentAs(now)) {
      return thisYear.difference(now).inDays;
    } else {
      return nextYear.difference(now).inDays;
    }
  }

  /// Gets the date of the next birthday.
  ///
  /// Returns the birthday this year if it hasn't occurred yet,
  /// otherwise returns the birthday next year.
  ///
  /// Returns: A [DateTime] representing the next birthday
  ///
  /// Example:
  /// ```dart
  /// final birthday = Birthday(name: 'John', birthDate: DateTime(1990, 3, 15));
  /// print(birthday.nextBirthday); // DateTime(2024, 3, 15) or DateTime(2025, 3, 15)
  /// ```
  DateTime get nextBirthday {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, birthDate.month, birthDate.day);

    if (thisYear.isAfter(now) || thisYear.isAtSameMomentAs(now)) {
      return thisYear;
    } else {
      return DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
  }

  /// Checks if today is their birthday.
  ///
  /// Returns true only if today's month and day match the birth date.
  ///
  /// Returns: true if today is their birthday, false otherwise
  bool get isBirthdayToday {
    final now = DateTime.now();
    return now.month == birthDate.month && now.day == birthDate.day;
  }

  /// Gets a human-readable formatted birth date.
  ///
  /// Format: "15 Mar 1990"
  ///
  /// Returns: Formatted date string
  String get formattedBirthDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${birthDate.day} ${months[birthDate.month - 1]} ${birthDate.year}';
  }
}