import 'package:flutter/material.dart';

class CustomListTitle extends StatelessWidget {
  const CustomListTitle({super.key, this.text, this.icon, this.onTap});

  final String? text;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon ?? icon, color: Color(0xFF115E38)),
      title: Text(text ?? 'Title'),
      onTap: onTap,
      trailing: Icon(Icons.chevron_right),
    );
  }
}
