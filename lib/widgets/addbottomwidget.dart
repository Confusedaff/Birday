import 'package:bday/widgets/selection.dart';
import 'package:flutter/material.dart';

class Addbottomwidget extends StatelessWidget {
  const Addbottomwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.deepPurple[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [

          SizedBox(
            height: 7,
          ),

          Selection(),

          SizedBox(
            height: 5,
          ),

          Selection(),

        ],
      ),
    );
  }
}