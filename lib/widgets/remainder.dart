import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/storage/notification.dart';
import 'package:flutter/foundation.dart';

class _ReminderLogger {
  static void info(String message) {
    if (kDebugMode) print('[REMINDER] $message');
  }
  
  static void success(String message) {
    if (kDebugMode) print('[REMINDER] ✓ $message');
  }
  
  static void warning(String message) {
    if (kDebugMode) print('[REMINDER] ⚠️ $message');
  }
  
  static void error(String message, [Object? e]) {
    if (kDebugMode) print('[REMINDER] ❌ $message${e != null ? '\n  Error: $e' : ''}');
  }
}

class BirthdayReminder {
  final NotiService _notiService = NotiService();

  // Generate a unique, deterministic notification ID from birthday
  int _generateNotificationId(Birthday birthday, int counter) {
    // Use hashCode for safety + counter to create unique IDs
    // This prevents collisions even if key is not an integer
    final baseId = birthday.name.hashCode.abs() + birthday.birthDate.millisecondsSinceEpoch.toInt().abs();
    return (baseId % 1000000) * 10 + counter;
  }

  // Cancel existing notifications before scheduling new ones
  Future<void> cancelBirthdayReminders(Birthday birthday) async {
    // Cancel all 4 possible notification IDs for this birthday
    for (int i = 0; i < 4; i++) {
      await _notiService.cancelNotification(_generateNotificationId(birthday, i));
    }
  }

  Future<void> scheduleBirthdayReminders(Birthday birthday) async {
    // Only schedule if reminder is enabled
    if (!birthday.isReminderEnabled) {
      // Cancel any existing notifications
      await cancelBirthdayReminders(birthday);
      return;
    }

    // Cancel existing notifications first to avoid duplicates
    await cancelBirthdayReminders(birthday);

    final nextBday = birthday.nextBirthday;
    final now = DateTime.now();

    // Reminder configurations - ONLY these 4 days are allowed
    final reminders = {
      30: "🎉 ${birthday.name}'s birthday is in 1 month!",
      15: "⏰ ${birthday.name}'s birthday is in 15 days!",
      1: "🥳 ${birthday.name}'s birthday is tomorrow!",
      0: "🎂 Today is ${birthday.name}'s birthday! 🎉",
    };

    int counter = 0;
    int successCount = 0;
    int failureCount = 0;

    for (final entry in reminders.entries) {
      final daysBefore = entry.key;
      final message = entry.value;

      // Calculate reminder date by subtracting days from next birthday
      final reminderDate = nextBday.subtract(Duration(days: daysBefore));
      
      // Set the time from alarm settings or default to 9:00 AM
      final scheduledDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        birthday.alarmTime?.hour ?? 9,
        birthday.alarmTime?.minute ?? 0,
      );

      // Skip if the reminder date is invalid (before today) or too far in the past
      if (scheduledDate.isBefore(now) || scheduledDate.difference(now).inDays < 0) {
        _ReminderLogger.warning('Skipping past reminder ($daysBefore days before) for ${birthday.name}: $scheduledDate');
        counter++;
        continue;
      }

      try {
        // Use safe, deterministic ID generation
        final notificationId = _generateNotificationId(birthday, counter);
        _ReminderLogger.info('Scheduling notification ID: $notificationId for ${birthday.name} at $scheduledDate');
        
        await _notiService.scheduleYearlyNotification(
          id: notificationId,
          title: "Birthday Reminder 🎂",
          body: message,
          scheduledDate: scheduledDate,
        );
        successCount++;
      } catch (e) {
        failureCount++;
        _ReminderLogger.error('Error scheduling notification for ${birthday.name}', e);
      }
      counter++;
    }

    if (successCount > 0) {
      _ReminderLogger.success('Scheduled $successCount reminder(s) for ${birthday.name}');
    }
    if (failureCount > 0) {
      _ReminderLogger.warning('Failed to schedule $failureCount reminder(s) for ${birthday.name}');
    }
  }

  static Future<void> scheduleAllReminders() async {
    final reminder = BirthdayReminder();
    final birthdays = HiveBirthdayService.getAllBirthdays();
    
    _ReminderLogger.info('Starting to schedule reminders for ${birthdays.length} birthday(ies)');
    
    for (final birthday in birthdays) {
      if (birthday.isReminderEnabled) {
        try {
          await reminder.scheduleBirthdayReminders(birthday);
        } catch (e) {
          _ReminderLogger.error('Error scheduling reminders for ${birthday.name}', e);
        }
      }
    }
    
    _ReminderLogger.success('Reminder scheduling completed');
  }
}
