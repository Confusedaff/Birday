import 'package:bday/widgets/remainder.dart';
import 'package:flutter/material.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/storage/hive.dart';

class Copybd {
  static Future<void> showTextImportDialog(BuildContext context) async {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Import Birthdays'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter birthdays in this format (one per line):',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '15/03/1990, John Doe\n22/07/1985, Jane Smith\n08/12/1992, Bob Johnson',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12,color: Color.fromARGB(255, 85, 46, 153),),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Paste or type your birthdays here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              String text = textController.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                _importBirthdaysFromText(context, text);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  static Future<void> _importBirthdaysFromText(
    BuildContext context, String text) async {
  try {
    List<Birthday> importedBirthdays = _parseBirthdayText(text);

    if (importedBirthdays.isNotEmpty) {
      final reminder = BirthdayReminder();
      
      for (var birthday in importedBirthdays) {
        await HiveBirthdayService.addBirthday(birthday);
        
        if (birthday.isReminderEnabled) {
          await reminder.scheduleBirthdayReminders(birthday);
        }
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Import Successful'),
            ],
          ),
          content: Text(
              'Successfully imported ${importedBirthdays.length} birthday${importedBirthdays.length == 1 ? '' : 's'}!'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Great!'),
            ),
          ],
        ),
      );
    } else {
      _showImportErrorDialog(context, 'No valid birthdays found in the text.');
    }
  } catch (e) {
    _showImportErrorDialog(context, 'Error parsing text: ${e.toString()}');
  }
}

  static List<Birthday> _parseBirthdayText(String text) {
  List<Birthday> birthdays = [];
  List<String> lines = text.split('\n');

  for (String line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;

    try {
      List<String> parts = line.split(',');
      if (parts.length >= 2) {
        String dateStr = parts[0].trim();
        String name = parts[1].trim();

        List<String> dateParts = dateStr.split('/');
        if (dateParts.length == 3) {
          int day = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int year = int.parse(dateParts[2]);

         if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year >= 1900) {
            DateTime birthDate = DateTime(year, month, day);
            DateTime defaultAlarmDate = DateTime(
              birthDate.year,
              birthDate.month,
              birthDate.day,
              9,
              0,
            ).subtract(const Duration(days: 1));

            final birthday = Birthday(
              name: name,
              birthDate: birthDate,
              alarmDate: defaultAlarmDate,
              alarmTimeHour: defaultAlarmDate.hour.toString(),
              alarmTimeMinute: defaultAlarmDate.minute.toString(),
              alarmId: DateTime.now().millisecondsSinceEpoch.toString(),
              isReminderEnabled: true,
            );

            birthdays.add(birthday);
          }
        }
      }
    } catch (_) {
      continue; 
    }
  }

  return birthdays;
}

  static void _showImportErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Import Error'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            const Text('Expected format:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '15/03/1990, John Doe\n22/07/1985, Jane Smith\n08/12/1992, Bob Johnson',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}