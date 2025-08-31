import 'package:bday/widgets/draghandle.dart';
import 'package:bday/widgets/selection.dart';
import 'package:bday/widgets/singlebday.dart';
import 'package:flutter/material.dart';

class Addbottomwidget extends StatelessWidget {
  const Addbottomwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

        Draghandle(width: 36),

        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Center(child: Text("Add Birthdays",style: TextStyle(fontSize: 25),)),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
        
            SizedBox(
              height: 5,
            ),
        
           Selection(
            icon: Icons.person_add_rounded, 
            title: 'Add Single Birthday',
            subtitle: 'Add one birthday manually',
            onTap: () { 
              showModalBottomSheet(
                context: context,
                builder: (context) => const Singlebday(),
              );
             }, 
            selectionBody: null,
            ),
        
            Selection(
            icon:Icons.edit_rounded,
            title: 'Import from Text',
            subtitle: 'Paste or type multiple birthdays',
            onTap: () { 
              print("Prssed Import button");
             }, 
            selectionBody: null,
            ),

          ],
        ),
        ],
      ),
    );
  }
}