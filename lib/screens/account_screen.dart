import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/screens/major_screen.dart';
import 'package:smart_expens/screens/monthly_buget_scrern.dart';
import 'package:smart_expens/screens/presonal_details.dart';
import 'package:smart_expens/widgets/list_title.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

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
                child: userProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: currentUser?.image != null
                                ? NetworkImage(currentUser!.image!)
                                : null,
                            child: currentUser?.image == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser?.name ?? '—',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF115E38),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  currentUser?.email ?? '—',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
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
              onTap: () async {
                try {
                  await userProvider.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MajorScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
