import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'hive.g.dart'; // This will be generated

@HiveType(typeId: 0)
class Birthday extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime birthDate;

  @HiveField(2)
  DateTime? alarmDate;

  @HiveField(3)
  String? alarmTimeHour;

  @HiveField(4)
  String? alarmTimeMinute;

  @HiveField(5)
  String? alarmId;

  @HiveField(6, defaultValue: false) // 👈 ensure default
  bool isReminderEnabled;

  Birthday({
    required this.name,
    required this.birthDate,
    this.alarmDate,
    this.alarmTimeHour,
    this.alarmTimeMinute,
    this.alarmId,
    this.isReminderEnabled = false,   // 👈 constructor default
  });

  // Helper method to get TimeOfDay from stored strings
  TimeOfDay? get alarmTime {
    if (alarmTimeHour != null && alarmTimeMinute != null) {
      return TimeOfDay(
        hour: int.parse(alarmTimeHour!),
        minute: int.parse(alarmTimeMinute!),
      );
    }
    return null;
  }

  // Helper method to set TimeOfDay as strings
  void setAlarmTime(TimeOfDay time) {
    alarmTimeHour = time.hour.toString();
    alarmTimeMinute = time.minute.toString();
  }

  // Calculate current age
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Calculate days until next birthday
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

  // Get next birthday date
  DateTime get nextBirthday {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, birthDate.month, birthDate.day);
    
    if (thisYear.isAfter(now) || thisYear.isAtSameMomentAs(now)) {
      return thisYear;
    } else {
      return DateTime(now.year + 1, birthDate.month, birthDate.day);
    }
  }

  // Check if birthday is today
  bool get isBirthdayToday {
    final now = DateTime.now();
    return now.month == birthDate.month && now.day == birthDate.day;
  }

  // Get formatted birth date
  String get formattedBirthDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${birthDate.day} ${months[birthDate.month - 1]} ${birthDate.year}';
  }
}