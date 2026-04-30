import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 200,
      child: Card(
        color: Colors.white,
        shadowColor: Colors.grey,
        elevation: 5,
        margin: const EdgeInsets.all(10),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }
}
