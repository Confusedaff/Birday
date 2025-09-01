import 'package:flutter/material.dart';

class Textfield extends StatefulWidget {
  final Widget? label;
  final String labeltext;
  final IconData? prefixIcon;
  final TextEditingController? controller;
 
  const Textfield({
    super.key,
    this.label,
    required this.labeltext,
    this.prefixIcon,
    this.controller,
  });
 
  @override
  State<Textfield> createState() => _TextfieldState();
}

class _TextfieldState extends State<Textfield> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
   
    return Padding(
      padding: const EdgeInsets.only(top: 16.0,left: 16,right: 16,bottom: 8),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.labeltext,
          labelStyle: TextStyle(
            fontSize: 18,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              width: 2.0, // Increase this value for thicker border
              color: theme.colorScheme.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              width: 3.0, // Border thickness when not focused
              color: theme.colorScheme.outline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              width: 3.0, // Thicker border when focused
              color: theme.colorScheme.primary,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 16.0,
          ),
          filled: true,
          fillColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
        ),
      ),
    );
  }
}