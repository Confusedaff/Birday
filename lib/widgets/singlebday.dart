import 'package:bday/storage/hive.dart';
import 'package:bday/storage/hive_service.dart';
import 'package:bday/widgets/button.dart';
import 'package:bday/widgets/dateselector.dart';
import 'package:bday/widgets/dragHandle.dart';
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
  DateTime? reminderDate;
  TimeOfDay? selectedAlarmTime;
  DateTime? selectedAlarmDate;
  bool _isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveInput() async {
    // Validate input
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
      // Create birthday object
      final birthday = Birthday(
        name: nameController.text.trim(),
        birthDate: birthDate!,
        alarmDate: selectedAlarmDate,
        alarmId: selectedAlarmTime != null ? DateTime.now().millisecondsSinceEpoch.toString() : null,
      );

      // Set alarm time if selected
      if (selectedAlarmTime != null) {
        birthday.setAlarmTime(selectedAlarmTime!);
      }

      // Save to Hive
      await HiveBirthdayService.addBirthday(birthday);

      // Create yearly alarm if time is set
      if (selectedAlarmTime != null && selectedAlarmDate != null) {
        await createYearlyAlarm(birthday.alarmId!);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Birthday for ${birthday.name} saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
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

  Future<void> createYearlyAlarm(String alarmId) async {
    if (selectedAlarmTime != null && selectedAlarmDate != null) {
      // Your existing alarm creation logic
      // final yearlyAlarm = TimeUtils.createYearlyAlarm(
      //   id: alarmId,
      //   time: selectedAlarmTime!,
      //   specificDate: selectedAlarmDate!,
      //   label: 'Birthday Reminder for ${nameController.text}',
      // );
      
      // Save the alarm to your storage/database
      // The alarm will now ring every year on the same date and time
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
              color: theme.colorScheme.shadow.withOpacity(0.1),
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
                    tap: () async {
                      // First pick the date
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );
                      
                      if (date != null) {
                        // Then pick the time
                        final time = await CustomTimePicker.showCustomTimePicker(
                          context: context,
                          helpText: 'Set Yearly Alarm Time',
                        );
                        
                        if (time != null) {
                          setState(() {
                            selectedAlarmTime = time;
                            selectedAlarmDate = date;
                          });
                        }
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Button(
                        text: 'Cancel',
                        tap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                      ),
                      Button(
                        text: _isSaving ? 'Saving...' : 'Add Birthday',
                        tap: _isSaving ? null : () {
                          _saveInput();
                        },
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