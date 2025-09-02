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
    final theme = Theme.of(context);
    return Transform.scale(
      scale: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: 5, bottom: 10),
        child: FloatingActionButton.extended(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          icon: const Icon(Icons.cake_rounded),
          label: Text(
            'Add Birthday',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 8,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const Addbottomwidget(),
            );
          },
        ),
      ),
    );
  }
}
