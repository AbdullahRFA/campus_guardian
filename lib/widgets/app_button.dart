import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // A function to be called when tapped

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Make the button take the full available width
      child: ElevatedButton(
        onPressed: onPressed,
        // The style is automatically picked up from the ElevatedButtonTheme
        // we defined in AppTheme on Day 2!
        child: Text(text),
      ),
    );
  }
}