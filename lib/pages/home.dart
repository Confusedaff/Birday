import 'package:bday/widgets/appbar.dart';
import 'package:bday/widgets/floatingButton.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(),
      body: const Center(child: Text("Home")),
      floatingActionButton: Floatingbutton()
    );
  }
}