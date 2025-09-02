import 'package:bday/widgets/button.dart';
import 'package:bday/widgets/dateselector.dart';
import 'package:bday/widgets/dragHandle.dart';
import 'package:bday/widgets/textfield.dart';
import 'package:flutter/material.dart';

class Singlebday extends StatefulWidget {
  const Singlebday({super.key});

  @override
  State<Singlebday> createState() => _SinglebdayState();
}

class _SinglebdayState extends State<Singlebday> {
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _saveInput() {
    String inputText = nameController.text;
    print("User entered: $inputText");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 500,//MediaQuery.of(context).size.height * 0.75,
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
                    text: 'Select Birth Date',
                    icon: Icons.cake_rounded,
                    tap: () async {
                      final selectedDate = await CustomDatePicker.showCustomDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        primaryColor: theme.colorScheme.primary,
                      );

                      if (selectedDate != null) {
                        print('Selected date: $selectedDate');
                        // Handle the selected date here
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: Dateselector(
                    height: 65,
                    width: MediaQuery.of(context).size.width - 32,
                    text: "Select Reminder Day",
                    icon: Icons.calendar_month_rounded,
                    tap: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
                  child: Dateselector(
                    height: 65,
                    width: MediaQuery.of(context).size.width - 32,
                    text: "Select Reminder Time",
                    icon: Icons.alarm_on_rounded,
                    tap: () {},
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
                          Navigator.pop(context);
                        },
                      ),
                      Button(
                        text: 'Add Birthday',
                        tap: _saveInput,
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