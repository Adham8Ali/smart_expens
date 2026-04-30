import 'package:flutter/material.dart';
import 'package:smart_expens/screen/major_screen.dart';
import 'package:smart_expens/screen/monthly_buget_scrern.dart';
import 'package:smart_expens/screen/presonal_details.dart';
import 'package:smart_expens/widget/list_title.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Card(
                elevation: 5,
                // margin: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      // backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF115E38),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'john.doe@example.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            CustomListTitle(
              text: 'Personal details',
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalDetailsScreen(),
                  ),
                );
              },
            ),
            CustomListTitle(
              text: 'Category Management',
              icon: Icons.category,
              onTap: () {
                // Handle category management tap
              },
            ),
            CustomListTitle(
              text: 'Monthly Budget',
              icon: Icons.calendar_today,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlyBudgetScreen(),
                  ),
                );
              },
            ),
            CustomListTitle(
              text: 'Logout',
              icon: Icons.logout,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MajorScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
