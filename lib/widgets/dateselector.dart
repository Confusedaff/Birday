import 'package:flutter/material.dart';

class Dateselector extends StatelessWidget {
  final double height;
  final double width;
  final String text;
  final IconData icon;
  final VoidCallback tap;
  const Dateselector({
    super.key,
    required this.height,
    required this.width,
    required this.text,
    required this.tap,
    required this.icon,
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
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
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

/// A reusable date picker widget with custom styling
class CustomDatePicker {
  /// Shows a styled date picker dialog
  static Future<DateTime?> showCustomDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    Color? primaryColor,
    double borderRadius = 20.0,
  }) async {
    final theme = Theme.of(context);

    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              backgroundColor: theme.colorScheme.surface,
              headerBackgroundColor: primaryColor ?? theme.colorScheme.primary,
              headerForegroundColor: theme.colorScheme.onPrimary,
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return primaryColor ?? theme.colorScheme.primary;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.onPrimary;
                }
                return null;
              }),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Utility class for date operations
class DateUtils {
  /// Calculate days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is in the future
  static bool isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Format date as DD/MM/YYYY
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format date as a readable string (e.g., "15 Mar 2024")
  static String formatDateReadable(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Get age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Get days until next birthday
  static int daysUntilBirthday(DateTime birthDate) {
    final now = DateTime.now();
    final thisYear = DateTime(now.year, birthDate.month, birthDate.day);
    final nextYear = DateTime(now.year + 1, birthDate.month, birthDate.day);

    if (thisYear.isAfter(now) || thisYear.isAtSameMomentAs(now)) {
      return thisYear.difference(now).inDays;
    } else {
      return nextYear.difference(now).inDays;
    }
  }
}
