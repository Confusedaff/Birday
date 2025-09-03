import 'package:bday/storage/hive.dart';
import 'package:bday/storage/notification.dart';

class BirthdayReminder {
  final NotiService _notiService = NotiService();

  Future<void> scheduleBirthdayReminders(Birthday birthday) async {
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
      
      if (reminderDate.isAfter(DateTime.now())) {
        final scheduledDate = DateTime(
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          birthday.alarmTime?.hour ?? 9,
          birthday.alarmTime?.minute ?? 0,
        );

        await _notiService.scheduleYearlyNotification(
          id: birthday.key.hashCode + counter,
          title: "Birthday Reminder",
          body: message,
          scheduledDate: scheduledDate,
        );
      }
      counter++;
    }
  }
}
