import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback tap;
  const Button({
    super.key,
    required this.text,
    required this.tap,
    });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 65,
      width: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: theme.colorScheme.primary.withOpacity(0.9),
      ),
      child: Center(
        child: GestureDetector(
          onTap: tap,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white//theme.colorScheme.primary.withOpacity(0.1),
            ),
            ),
        )),
    );
  }
}