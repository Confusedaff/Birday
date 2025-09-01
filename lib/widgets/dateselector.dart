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
    return GestureDetector(
      onTap: tap,
      child: Container(
        height: height,//65,
        width: width,//380,
        decoration: BoxDecoration(
          //color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
          border: BoxBorder.all(
            color:  const Color.fromARGB(255, 117, 111, 111),//theme.colorScheme.primary,
            width: 3.5,
            ),
        ),
        child: Row(
          children: [
      
            Padding(
              padding: const EdgeInsets.only(left:10.0),
              child: Icon(
                icon,//Icons.cake_rounded,
                color:  const Color.fromARGB(255, 101, 101, 101),
                size: 28,
                ),
            ),
      
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                text,//"Select Birth Date",
                style: TextStyle(
                  fontSize: 18,
                  color:  const Color.fromARGB(255, 101, 101, 101),
                  fontWeight: FontWeight.w400
                ),
                ),
            )
          ],
        )
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