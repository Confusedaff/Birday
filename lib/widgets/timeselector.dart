import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final double height;
  final double width;
  final String placeholder; // what to show before a time is picked
  final IconData icon;
  final TimeOfDay? selectedTime; // the picked time (nullable)
  final VoidCallback tap;
  final bool is24HourFormat;

  const TimeSelector({
    super.key,
    required this.height,
    required this.width,
    required this.placeholder,
    required this.icon,
    required this.tap,
    this.selectedTime,
    this.is24HourFormat = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outline,
              width: 2.0,
            ),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    selectedTime != null
                        ? TimeUtils.formatTime(selectedTime!, is24HourFormat)
                        : placeholder, // show time or placeholder
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable alarm time picker widget with custom styling
class CustomTimePicker {
  /// Shows a styled time picker dialog for alarm setting
  static Future<TimeOfDay?> showCustomTimePicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Color? primaryColor,
    double borderRadius = 20.0,
    bool is24HourFormat = false,
  }) async {
    final theme = Theme.of(context);

    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      helpText: helpText ?? 'Set Alarm Time',
      cancelText: cancelText,
      confirmText: confirmText,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: is24HourFormat,
          ),
          child: Theme(
            data: theme.copyWith(
              timePickerTheme: TimePickerThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                backgroundColor: theme.colorScheme.surface,
                hourMinuteColor: theme.colorScheme.surfaceVariant,
                hourMinuteTextColor: theme.colorScheme.onSurfaceVariant,
                dialBackgroundColor: theme.colorScheme.surfaceVariant,
                dialHandColor: primaryColor ?? theme.colorScheme.primary,
                dialTextColor: theme.colorScheme.onSurfaceVariant,
                entryModeIconColor: theme.colorScheme.onSurfaceVariant,
                dayPeriodColor: theme.colorScheme.primaryContainer,
                dayPeriodTextColor: theme.colorScheme.onPrimaryContainer,
                helpTextStyle: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

/// Alarm model class
class AlarmModel {
  final String id;
  final TimeOfDay time;
  final DateTime? specificDate; // For yearly recurring alarms
  final String label;
  final List<int> selectedDays; // 1-7 for Monday-Sunday
  final bool isEnabled;
  final String ringtone;
  final bool vibrate;
  final int snoozeInterval; // minutes
  final bool isYearlyRecurring; // New field for yearly recurring alarms

  const AlarmModel({
    required this.id,
    required this.time,
    this.specificDate,
    this.label = '',
    this.selectedDays = const [],
    this.isEnabled = true,
    this.ringtone = 'Default',
    this.vibrate = true,
    this.snoozeInterval = 10,
    this.isYearlyRecurring = false,
  });

  AlarmModel copyWith({
    String? id,
    TimeOfDay? time,
    DateTime? specificDate,
    String? label,
    List<int>? selectedDays,
    bool? isEnabled,
    String? ringtone,
    bool? vibrate,
    int? snoozeInterval,
    bool? isYearlyRecurring,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      specificDate: specificDate ?? this.specificDate,
      label: label ?? this.label,
      selectedDays: selectedDays ?? this.selectedDays,
      isEnabled: isEnabled ?? this.isEnabled,
      ringtone: ringtone ?? this.ringtone,
      vibrate: vibrate ?? this.vibrate,
      snoozeInterval: snoozeInterval ?? this.snoozeInterval,
      isYearlyRecurring: isYearlyRecurring ?? this.isYearlyRecurring,
    );
  }

  /// Check if alarm is set for today
  bool isSetForToday() {
    final now = DateTime.now();
    
    if (isYearlyRecurring && specificDate != null) {
      // Check if today matches the specific date (month and day)
      return now.month == specificDate!.month && now.day == specificDate!.day;
    }
    
    if (selectedDays.isEmpty) return true; // One-time alarm
    final today = now.weekday;
    return selectedDays.contains(today);
  }

  /// Get next alarm trigger time
  DateTime? getNextTriggerTime() {
    final now = DateTime.now();
    
    if (isYearlyRecurring && specificDate != null) {
      // For yearly recurring alarms
      return _getNextYearlyOccurrence(now);
    }
    
    final alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (selectedDays.isEmpty) {
      // One-time alarm
      if (alarmDateTime.isAfter(now)) {
        return alarmDateTime;
      } else {
        return alarmDateTime.add(const Duration(days: 1));
      }
    } else {
      // Weekly recurring alarm
      for (int i = 0; i < 7; i++) {
        final checkDate = now.add(Duration(days: i));
        final checkDateTime = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          time.hour,
          time.minute,
        );

        if (selectedDays.contains(checkDate.weekday) &&
            checkDateTime.isAfter(now)) {
          return checkDateTime;
        }
      }
    }
    return null;
  }

  /// Helper method to get next yearly occurrence
  DateTime _getNextYearlyOccurrence(DateTime now) {
    if (specificDate == null) return now;
    
    // Create alarm time for this year
    var thisYearAlarm = DateTime(
      now.year,
      specificDate!.month,
      specificDate!.day,
      time.hour,
      time.minute,
    );
    
    // If the alarm time this year has already passed, set it for next year
    if (thisYearAlarm.isBefore(now) || thisYearAlarm.isAtSameMomentAs(now)) {
      thisYearAlarm = DateTime(
        now.year + 1,
        specificDate!.month,
        specificDate!.day,
        time.hour,
        time.minute,
      );
    }
    
    return thisYearAlarm;
  }
}

/// Utility class for time operations
class TimeUtils {
  /// Format TimeOfDay as string (12 or 24 hour format)
  static String formatTime(TimeOfDay time, bool is24Hour) {
    if (is24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Convert TimeOfDay to minutes since midnight
  static int timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// Convert minutes since midnight to TimeOfDay
  static TimeOfDay minutesToTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Get time until next alarm
  static String getTimeUntilAlarm(DateTime nextAlarmTime) {
    final now = DateTime.now();
    final difference = nextAlarmTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h ${difference.inMinutes % 60}m';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  /// Get day names from numbers (1-7)
  static List<String> getDayNames(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((day) => dayNames[day - 1]).toList();
  }

  /// Get formatted day string for alarm display
  static String formatAlarmDays(List<int> days, {bool isYearlyRecurring = false, DateTime? specificDate}) {
    if (isYearlyRecurring && specificDate != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return 'Every ${specificDate.day} ${months[specificDate.month - 1]}';
    }
    
    if (days.isEmpty) return 'Once';
    if (days.length == 7) return 'Every day';
    if (days.length == 5 && days.every((day) => day <= 5)) return 'Weekdays';
    if (days.length == 2 && days.contains(6) && days.contains(7)) return 'Weekends';
    
    return getDayNames(days).join(', ');
  }

  /// Check if current time matches alarm time (within 1 minute)
  static bool isTimeMatch(TimeOfDay alarmTime, TimeOfDay currentTime) {
    return alarmTime.hour == currentTime.hour && 
           alarmTime.minute == currentTime.minute;
  }

  /// Get next occurrence of a specific time
  static DateTime getNextOccurrence(TimeOfDay time, {List<int>? onDays, bool isYearlyRecurring = false, DateTime? specificDate}) {
    final now = DateTime.now();
    
    if (isYearlyRecurring && specificDate != null) {
      // For yearly recurring alarms
      var thisYearAlarm = DateTime(
        now.year,
        specificDate.month,
        specificDate.day,
        time.hour,
        time.minute,
      );
      
      // If the alarm time this year has already passed, set it for next year
      if (thisYearAlarm.isBefore(now) || thisYearAlarm.isAtSameMomentAs(now)) {
        thisYearAlarm = DateTime(
          now.year + 1,
          specificDate.month,
          specificDate.day,
          time.hour,
          time.minute,
        );
      }
      
      return thisYearAlarm;
    }
    
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    if (onDays == null || onDays.isEmpty) {
      // One-time alarm
      if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }
    
    // Find next day that matches the criteria
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final candidate = DateTime(
        checkDate.year, 
        checkDate.month, 
        checkDate.day, 
        time.hour, 
        time.minute
      );
      
      if (onDays.contains(checkDate.weekday) && candidate.isAfter(now)) {
        return candidate;
      }
    }
    
    return next; // fallback
  }

  /// Create a yearly recurring alarm
  static AlarmModel createYearlyAlarm({
    required String id,
    required TimeOfDay time,
    required DateTime specificDate,
    String label = '',
    String ringtone = 'Default',
    bool vibrate = true,
    int snoozeInterval = 10,
  }) {
    return AlarmModel(
      id: id,
      time: time,
      specificDate: specificDate,
      label: label,
      isYearlyRecurring: true,
      ringtone: ringtone,
      vibrate: vibrate,
      snoozeInterval: snoozeInterval,
    );
  }

  /// Get years until next occurrence for yearly alarms
  static String getTimeUntilYearlyAlarm(DateTime nextAlarmTime) {
    final now = DateTime.now();
    final difference = nextAlarmTime.difference(now);
    
    if (difference.inDays >= 365) {
      final years = difference.inDays ~/ 365;
      final remainingDays = difference.inDays % 365;
      return '${years}y ${remainingDays}d';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }
}