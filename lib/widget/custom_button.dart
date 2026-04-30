import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    this.text,
    this.textcolor,
    this.buttoncolor,
    this.onPressed,
  });
  String? text;
  Color? textcolor;
  Color? buttoncolor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // fixedSize: MaterialStateProperty.all(Size(150, 40)),
        backgroundColor: WidgetStateProperty.all(buttoncolor),
        foregroundColor: WidgetStateProperty.all(textcolor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: const BorderSide(
              color: Color(0xff115E38), // لون الحافة
              width: 2, // سُمك الحافة
            ),
            borderRadius: BorderRadius.circular(8), // Default border radius
          ),
        ),
      ),
      child: Text(text!, style: TextStyle(fontSize: 20)),
    );
  }
}
