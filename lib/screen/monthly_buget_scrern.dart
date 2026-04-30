import 'package:flutter/material.dart';

class MonthlyBudgetScreen extends StatelessWidget {
  final double totalBudget = 2500;
  final double currentSpending = 1847;

  const MonthlyBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double percentUsed = currentSpending / totalBudget;

    return Scaffold(
      appBar: AppBar(title: Text("Monthly Budget")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Monthly Budget",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${totalBudget.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 24, color: Colors.black87),
            ),
            SizedBox(height: 20),
            Text(
              "Current Spending",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "\$${currentSpending.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 24, color: Colors.black87),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: percentUsed,
              backgroundColor: Colors.green.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentUsed < 0.75 ? Colors.green : Colors.orange,
              ),
              minHeight: 12,
            ),
            SizedBox(height: 10),
            Text(
              "${(percentUsed * 100).toStringAsFixed(0)}% of budget used",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // هنا تقدر تضيف منطق حفظ الميزانية
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Save Budget", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
