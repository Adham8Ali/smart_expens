import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget circleBtn(IconData icon) {
  return Container(
    height: 50,
    width: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Icon(icon),
  );
}
