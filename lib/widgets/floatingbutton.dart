import 'package:bday/widgets/addbottomwidget.dart';
import 'package:flutter/material.dart';

class Floatingbutton extends StatefulWidget {
  const Floatingbutton({super.key});

  @override
  State<Floatingbutton> createState() => _FloatingbuttonState();
}

class _FloatingbuttonState extends State<Floatingbutton> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1,
      child: Padding(
        padding:  const EdgeInsets.only(right: 10,bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.deepPurple[200],
          //shape: const CircleBorder(),
          icon: Icon(Icons.cake_rounded),
          label: Text('Add Birthday'),
          elevation: 8,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const Addbottomwidget(),
            );
          },
        ),
      ),
    );
  }
}