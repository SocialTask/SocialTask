import 'package:flutter/material.dart';
import 'package:socialtask/utils/lang.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed; // Callback function to handle button press
  final BuildContext context; // Build context to use for navigation

  const AnimatedButton(
      {super.key, required this.onPressed, required this.context});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isButtonPressed = true),
      onTapUp: (_) {
        setState(() => _isButtonPressed = false);
        // Handle button click here
        widget.onPressed(); // Call the provided callback function
      },
      onTapCancel: () {
        setState(() => _isButtonPressed = false);
        // Handle button click here (e.g., if needed)
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: _isButtonPressed
              ? const LinearGradient(
                  colors: [Color(0xFFEE8A24), Color(0xFFFDCB53)])
              : const LinearGradient(
                  colors: [Color(0xFFFFCC00), Colors.orange]),
        ),
        child: Text(
          AppLocalizations.of(context).translate('start'),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
