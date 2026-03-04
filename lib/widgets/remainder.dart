import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/storage/notification.dart';
import 'package:bday/services/logger_service.dart';
import 'package:bday/config/app_constants.dart';

/// Service for managing birthday reminders and scheduling notifications.
///
/// This class handles all reminder-related logic including:
/// - Scheduling yearly notifications for upcoming birthdays
/// - Canceling reminders when disabled
/// - Generating unique, deterministic notification IDs
/// - Managing multiple reminders per birthday (30 days, 15 days, 1 day, day-of)
///
/// The service ensures:
/// - No duplicate notifications
/// - Past reminders are skipped
/// - Reminders respect user's custom alarm times
/// - All operations are logged for debugging
class BirthdayReminder {
  final NotiService _notiService = NotiService();

  /// Generates a unique, deterministic notification ID for a birthday reminder.
  ///
  /// Uses a combination of the birthday's name and date hash plus a counter
  /// to create unique IDs. This ensures the same birthday always generates
  /// the same base ID, allowing for reliable cancellation.
  ///
  /// The algorithm:
  /// 1. Hash the birthday name and timestamp to get a base value
  /// 2. Modulo to fit within reasonable range (1,000,000)
  /// 3. Multiply by 10 and add counter to create unique IDs for each reminder type
  ///
  /// Parameters:
  ///   - birthday: The birthday to generate an ID for
  ///   - counter: The reminder index (0-3 for the 4 reminder types)
  ///
  /// Returns: A unique integer ID for the notification
  ///
  /// Example:
  /// ```dart
  /// // For "John" born 1990-03-15:
  /// // Counter 0: 123450 (30 days before)
  /// // Counter 1: 123451 (15 days before)
  /// // Counter 2: 123452 (1 day before)
  /// // Counter 3: 123453 (day of)
  /// ```
  int _generateNotificationId(Birthday birthday, int counter) {
    final baseId = birthday.name.hashCode.abs() +
        birthday.birthDate.millisecondsSinceEpoch.toInt().abs();
    return (baseId % 1000000) * 10 + counter;
  }

  /// Cancels all reminders for a birthday.
  ///
  /// Removes all 4 scheduled notifications (30 days, 15 days, 1 day, and day-of).
  /// Safe to call even if some or all notifications aren't scheduled.
  ///
  /// Parameters:
  ///   - birthday: The birthday whose reminders should be canceled
  Future<void> cancelBirthdayReminders(Birthday birthday) async {
    try {
      for (int i = 0; i < 4; i++) {
        await _notiService
            .cancelNotification(_generateNotificationId(birthday, i));
      }
      AppLogger.debug('Canceled all reminders for ${birthday.name}');
    } catch (e) {
      AppLogger.error(
        'Error canceling reminders for ${birthday.name}',
        error: e,
      );
    }
  }

  /// Schedules reminders for a birthday.
  ///
  /// Schedules up to 4 yearly notifications for each birthday:
  /// - 30 days before
  /// - 15 days before
  /// - 1 day before
  /// - Day of the birthday
  ///
  /// The method:
  /// 1. Cancels any existing reminders to avoid duplicates
  /// 2. Checks if reminders are enabled (if not, just cancels)
  /// 3. Calculates the next birthday
  /// 4. Schedules reminders at the user's custom time or default 9:00 AM
  /// 5. Skips any reminders that would be in the past
  ///
  /// Parameters:
  ///   - birthday: The birthday to schedule reminders for
  Future<void> scheduleBirthdayReminders(Birthday birthday) async {
    // If reminders are disabled, cancel any existing ones
    if (!birthday.isReminderEnabled) {
      await cancelBirthdayReminders(birthday);
      return;
    }

    // Cancel existing notifications first to avoid duplicates
    await cancelBirthdayReminders(birthday);

    final nextBday = birthday.nextBirthday;
    final now = DateTime.now();

    // Reminder configurations from constants
    final reminders = AppConstants.reminderMessages;

    int counter = 0;
    int successCount = 0;
    int failureCount = 0;

    for (final entry in reminders.entries) {
      final daysBefore = entry.key;
      final message = entry.value;

      // Calculate reminder date by subtracting days from next birthday
      final reminderDate = nextBday.subtract(Duration(days: daysBefore));

      // Set the time from alarm settings or use default
      final scheduledDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        birthday.alarmTime?.hour ?? AppConstants.defaultReminderHour,
        birthday.alarmTime?.minute ?? AppConstants.defaultReminderMinute,
      );

      // Skip if the reminder date is in the past
      if (scheduledDate.isBefore(now) ||
          scheduledDate.difference(now).inDays < 0) {
        AppLogger.debug(
          'Skipped past reminder ($daysBefore days before) for ${birthday.name}: $scheduledDate',
        );
        counter++;
        continue;
      }

      try {
        final notificationId = _generateNotificationId(birthday, counter);

        await _notiService.scheduleYearlyNotification(
          id: notificationId,
          title: 'Birthday Reminder 🎂',
          body: message,
          scheduledDate: scheduledDate,
        );
        successCount++;
      } catch (e) {
        failureCount++;
        AppLogger.error(
          'Error scheduling reminder for ${birthday.name}',
          error: e,
        );
      }
      counter++;
    }

    if (successCount > 0) {
      AppLogger.info(
        'Scheduled $successCount reminder(s) for ${birthday.name}',
      );
    }
    if (failureCount > 0) {
      AppLogger.warning(
        'Failed to schedule $failureCount reminder(s) for ${birthday.name}',
      );
    }
  }

  /// Schedules reminders for all birthdays in the database.
  ///
  /// This is a static method that's typically called during app initialization.
  /// It iterates through all birthdays and schedules reminders for those that
  /// have reminders enabled.
  ///
  /// This method is safe to call even if no birthdays exist (will do nothing).
  /// Any errors scheduling individual birthdays are logged but don't prevent
  /// other birthdays from being processed.
  static Future<void> scheduleAllReminders() async {
    try {
      final reminder = BirthdayReminder();
      final birthdays = HiveBirthdayService.getAllBirthdays();

      AppLogger.info(
        'Scheduling reminders for ${birthdays.length} birthday(ies)',
      );

      for (final birthday in birthdays) {
        if (birthday.isReminderEnabled) {
          try {
            await reminder.scheduleBirthdayReminders(birthday);
          } catch (e) {
            AppLogger.error(
              'Error scheduling reminders for ${birthday.name}',
              error: e,
            );
          }
        }
      }

      AppLogger.info('Reminder scheduling completed');
    } catch (e) {
      AppLogger.error(
        'Error in scheduleAllReminders',
        error: e,
      );
    }
  }
}
