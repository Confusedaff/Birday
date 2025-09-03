import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/storage/notification.dart';

class BirthdayReminder {
  final NotiService _notiService = NotiService();

  // Cancel existing notifications before scheduling new ones
  Future<void> cancelBirthdayReminders(Birthday birthday) async {
    await _notiService.cancelBirthdayNotifications(birthday.key);
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

    // Reminder texts
    final reminders = {
      30: "🎉 ${birthday.name}'s birthday is in 1 month!",
      15: "⏰ ${birthday.name}'s birthday is in 15 days!",
      1: "🥳 ${birthday.name}'s birthday is tomorrow!",
      0: "🎂 Today is ${birthday.name}'s birthday! 🎉",
    };

    int counter = 0;
    for (final entry in reminders.entries) {
      final daysBefore = entry.key;
      final message = entry.value;

      final reminderDate = nextBday.subtract(Duration(days: daysBefore));
      
      // Set the time from alarm settings or default to 9:00 AM
      final scheduledDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        birthday.alarmTime?.hour ?? 9,
        birthday.alarmTime?.minute ?? 0,
      );

      // Only schedule if it's in the future
      if (scheduledDate.isAfter(DateTime.now())) {
        await _notiService.scheduleYearlyNotification(
          id: birthday.key.hashCode + counter,
          title: "Birthday Reminder 🎂",
          body: message,
          scheduledDate: scheduledDate,
        );
        print('Scheduled notification for ${birthday.name} on $scheduledDate');
      }
      counter++;
    }
  }


  static Future<void> scheduleAllReminders() async {
    final reminder = BirthdayReminder();
    final birthdays = HiveBirthdayService.getAllBirthdays();
    
    for (final birthday in birthdays) {
      if (birthday.isReminderEnabled) {
        await reminder.scheduleBirthdayReminders(birthday);
      }
    }
  }
}