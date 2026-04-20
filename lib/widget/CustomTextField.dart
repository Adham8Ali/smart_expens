import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  CustomTextfield({
    super.key,
    required this.hintText,
    this.icon,
    required TextInputType keypadType,
    this.obscureText = false,
  });
  String? hintText;
  IconData? icon;
  TextInputType? keypadType;
  bool? obscureText;
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText!,
      keyboardType: keypadType,
      // obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Color(0xff105D38)),
        prefixIcon: Icon(icon, color: Color(0xff105D38)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
