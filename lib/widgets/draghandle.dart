import 'package:flutter/material.dart';

class Draghandle extends StatelessWidget {
  final double width;
  const Draghandle({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}