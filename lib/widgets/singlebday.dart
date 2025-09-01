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
    
    super.dispose();
  }

  void _saveInput() {
    
    String inputText = nameController.text;
    print("User entered: $inputText");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Saved: $inputText")),
    // );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
       onTap: () => FocusScope.of(context).unfocus(),
       behavior: HitTestBehavior.opaque,
      child: Container(
        height: 400,
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  Draghandle(width: 140),
      
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Add Birthday",
                      style: TextStyle(
                        fontSize:25
                      ),
                    ),
                  ),
      
                  SizedBox(
                    height: 5,
                  ),
      
                  Textfield(
                    labeltext: "Name",
                     prefixIcon: Icons.person_rounded,
                     controller: nameController,
                    ),

                    Padding(
                      padding:  const EdgeInsets.only(left: 16,right: 16,bottom: 8),
                      child: Dateselector(
                        height: 65,
                        width: 380,
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

                    Dateselector(
                      height: 65, 
                      width: 380, 
                      text: "Select Remainder Time", 
                      icon: Icons.alarm_add_outlined,
                      tap: () {

                      }, 
                      ),

                     Padding(
                       padding: const EdgeInsets.only(top: 8,bottom: 8),
                       child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Button(
                              text: 'Cancel', 
                              tap: () {  
                                 Navigator.popUntil(context, (route) => route.isFirst);
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
              )
            ),
          ],
        ),
      ),
    );
  }
}