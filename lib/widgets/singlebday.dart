import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/widgets/button.dart';
import 'package:bday/widgets/dateselector.dart';
import 'package:bday/widgets/draghandle.dart';
import 'package:bday/widgets/remainder.dart';
import 'package:bday/widgets/textfield.dart';
import 'package:bday/widgets/timeselector.dart';
import 'package:flutter/material.dart';

class Singlebday extends StatefulWidget {
  const Singlebday({super.key});

  @override
  State<Singlebday> createState() => _SinglebdayState();
}

class _SinglebdayState extends State<Singlebday> {
  final TextEditingController nameController = TextEditingController();
  DateTime? birthDate;
  TimeOfDay? selectedAlarmTime;
  bool _isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveInput() async {
    if (nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a name');
      return;
    }

    if (birthDate == null) {
      _showErrorDialog('Please select a birth date');
      return;
    }

    setState(() => _isSaving = true);

  try {
    final birthday = Birthday(
      name: nameController.text.trim(),
      birthDate: birthDate!,
      isReminderEnabled: selectedAlarmTime != null,
    );
    if (selectedAlarmTime != null) {
      birthday.setAlarmTime(selectedAlarmTime!);
    }

    await HiveBirthdayService.addBirthday(birthday);

    if (birthday.isReminderEnabled) {
      final reminder = BirthdayReminder();
      await reminder.scheduleBirthdayReminders(birthday);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Birthday for ${birthday.name} saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  } catch (e) {
    if (mounted) {
      _showErrorDialog('Failed to save birthday: ${e.toString()}');
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAlarmTimeTap(BuildContext currentContext) async {
    // Reminders recur yearly automatically on the birthday's own date, so
    // only the time of day needs to be picked here - a separate date
    // picker isn't needed and only added confusing, pointless friction.
    final time = await CustomTimePicker.showCustomTimePicker(
      context: currentContext,
      helpText: 'Set Reminder Time',
    );

    if (!mounted || time == null) return;

    setState(() {
      selectedAlarmTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Draghandle(width: 140),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    "Add Birthday",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Textfield(
                  labeltext: "Name",
                  prefixIcon: Icons.person_rounded,
                  controller: nameController,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Dateselector(
                    height: 65,
                    width: MediaQuery.of(context).size.width - 32,
                    placeholder: 'Select Birth Date',
                    icon: Icons.cake_rounded,
                    selectedDate: birthDate,
                    tap: () async {
                      final selected = await CustomDatePicker.showCustomDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        primaryColor: theme.colorScheme.primary,
                      );
                      if (selected != null) {
                        setState(() => birthDate = selected);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
                  child: TimeSelector(
                    height: 65,
                    width: MediaQuery.of(context).size.width - 32,
                    placeholder: "Select Alarm Time",
                    icon: Icons.alarm_add_rounded,
                    selectedTime: selectedAlarmTime,
                    tap: () => _handleAlarmTimeTap(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Button(
                          text: 'Cancel',
                          tap: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Button(
                          text: _isSaving ? 'Saving...' : 'Add Birthday',
                          tap: _isSaving ? null : () {
                            _saveInput();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}