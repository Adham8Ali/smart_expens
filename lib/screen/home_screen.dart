import 'package:flutter/material.dart';
import 'package:smart_expens/screen/account_screen.dart';
import 'package:smart_expens/screen/expense_screen.dart';
import 'package:smart_expens/screen/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Define monthly spending and budget as variables for calculation
    double monthlySpending = 0.00;
    double monthlyBudget = 6000.0;
    double progress = monthlySpending / monthlyBudget;

    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Spend', style: TextStyle(color: Color(0xff115E38))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // container for monthly spending
            // container 1
            Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'monthly spending',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xff6B7280),
                      ),
                    ],
                  ),

                  // shoud edit
                  Text(
                    '${monthlySpending.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xff115E38),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // shoud edit
                  Text(
                    '+12.5% vs last month',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // container for monthly budget
            // container 2
            Container(
              child: Column(
                children: [
                  Text(
                    'monthly budget',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // shoud edit
                  Text(
                    '${monthlyBudget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xff115E38),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Used"),
                      Text("${(progress * 100).toStringAsFixed(1)}%"),
                    ],
                  ),

                  SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                  ),
                  // shoud edit
                  Text(
                    'monthly budget',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            // container for spending trend
            // container 3
            Container(
              child: Column(
                children: [
                  Text(
                    'monthly budget',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // shoud edit
                  Text(
                    '${monthlyBudget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xff115E38),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
