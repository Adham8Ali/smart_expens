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
      child: Text(text!, style: TextStyle(fontSize: 20)),
      style: ButtonStyle(
        // fixedSize: MaterialStateProperty.all(Size(150, 40)),
        backgroundColor: MaterialStateProperty.all(buttoncolor),
        foregroundColor: MaterialStateProperty.all(textcolor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            side: const BorderSide(
              color: Color(0xff115E38), // لون الحافة
              width: 2, // سُمك الحافة
            ),
            borderRadius: BorderRadius.circular(8), // Default border radius
          ),
        ),
      ),
    );
  }
}
