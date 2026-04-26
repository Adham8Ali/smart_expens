import 'package:flutter/material.dart';

class PersonalDetailsScreen extends StatelessWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Personal Details'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildItem('Name', 'Adham Ali', Icons.person),
            buildItem('Email', 'adham@email.com', Icons.email),
            buildItem('Password', '********', Icons.lock),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // زرار أخضر
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Update Data',
                  style: TextStyle(color: Colors.white), // الكلام أبيض
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white, // خلفية غامقة عشان الأبيض يبان
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black, // الحواف سوداء
              width: 1.5, // سمك البوردر (تقدر تزوده أو تقلله)
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 10),
              Expanded(
                child: Text(value, style: const TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
