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
      scale: 1.3,
      child: Padding(
        padding:  const EdgeInsets.only(right: 10,bottom: 10),
        child: FloatingActionButton(
          backgroundColor: Colors.deepPurple[200],
          shape: const CircleBorder(),
          onPressed: () {
             print('FAB pressed!');
          },
           child: const Icon(Icons.cake),
        ),
      ),
    );
  }
}