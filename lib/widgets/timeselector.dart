import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final double height;
  final double width;
  final String placeholder; 
  final IconData icon;
  final TimeOfDay? selectedTime;
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
                color: theme.colorScheme.shadow.withValues(alpha: 0.1),
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
                        : placeholder,
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                hourMinuteColor: theme.colorScheme.surfaceContainerHighest,
                hourMinuteTextColor: theme.colorScheme.onSurfaceVariant,
                dialBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                dialHandColor: primaryColor ?? theme.colorScheme.primary,
                dialTextColor: Colors.white,
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

/// Utility for formatting a TimeOfDay for display.
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
}