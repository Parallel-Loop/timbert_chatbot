import 'package:flutter/material.dart';

class AddResponseButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const AddResponseButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "הוסף נתונים",
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onPressed,
        child: Container(
          width: 32,
          height: 35,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
