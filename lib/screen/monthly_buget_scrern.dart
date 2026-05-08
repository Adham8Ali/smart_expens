import 'package:flutter/material.dart';
import 'package:smart_expens/screen/home_screen.dart';
import 'package:smart_expens/screen/navBar_screen.dart';

class MonthlyBudgetScreen extends StatefulWidget {
  const MonthlyBudgetScreen({super.key});

  @override
  State<MonthlyBudgetScreen> createState() => _MonthlyBudgetScreenState();
}

class _MonthlyBudgetScreenState extends State<MonthlyBudgetScreen> {
  final TextEditingController budgetController = TextEditingController();

  double currentSpending = 1847;

  @override
  Widget build(BuildContext context) {
    double budget =
        double.tryParse(
          budgetController.text.isEmpty ? "0" : budgetController.text,
        ) ??
        0;

    double percent = budget == 0 ? 0 : currentSpending / budget;

    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F5),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        title: const Text(
          "Monthly Budget",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            const Text(
              "Total Monthly Budget",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 20),

            /// TextField
            Container(
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Center(
                child: TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "2500",
                  ),

                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ),

            const SizedBox(height: 50),

            /// Current Spending
            const Center(
              child: Text(
                "Current Spending",
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                "\$${currentSpending.toInt()}",
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: percent > 1 ? 1 : percent,
                minHeight: 14,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              ),
            ),

            const SizedBox(height: 15),

            /// Percent Text
            Center(
              child: Text(
                "${(percent * 100).toInt()}% of budget used",
                style: const TextStyle(fontSize: 22, color: Colors.grey),
              ),
            ),

            const Spacer(),

            /// Save Button
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0E6B3E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NavbarScreen(
                        monthlyBudget:
                            double.tryParse(budgetController.text) ?? 0,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Save Budget",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// /// الصفحة التانية
// class SecondScreen extends StatelessWidget {
//   const SecondScreen({super.key, required this.monthlyBudget});

//   final String monthlyBudget;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Second Screen")),
//       body: Center(
//         child: Text(
//           "Budget = $monthlyBudget",
//           style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
