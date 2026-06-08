import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      elevation: 5,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );

    // If height is explicitly provided, constrain it.
    // If height is null, let the card size itself to its content.
    if (height != null) {
      return SizedBox(height: height, child: card);
    }
    return card;
  }
}
