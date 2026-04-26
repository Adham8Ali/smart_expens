import 'package:flutter/material.dart';
import 'package:smart_expens/screen/major_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'final project collage',
      debugShowCheckedModeBanner: false,
      home: MajorScreen(),
    );
  }
}
