import 'package:bday/widgets/draghandle.dart';
import 'package:bday/widgets/selection.dart';
import 'package:bday/widgets/singlebday.dart';
import 'package:flutter/material.dart';

class Addbottomwidget extends StatelessWidget {
  const Addbottomwidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 320,
      width: double.infinity,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Draghandle(width: 36),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Center(
              child: Text(
                "Add Birthdays",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 5),
              Selection(
                icon: Icons.person_add_rounded,
                title: 'Add Single Birthday',
                subtitle: 'Add one birthday manually',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const Singlebday(),
                  );
                },
                selectionBody: null,
              ),
              Selection(
                icon: Icons.edit_rounded,
                title: 'Import from Text',
                subtitle: 'Paste or type multiple birthdays',
                onTap: () {
                  print("Pressed Import button");
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