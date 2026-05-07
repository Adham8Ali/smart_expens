import 'package:flutter/material.dart';
import 'package:smart_expens/screen/account_screen.dart';
import 'package:smart_expens/widget/custom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Define monthly spending and budget as variables for calculation
    double monthlySpending = 5000.00;
    double monthlyBudget = 10000.00;
    double progress = monthlySpending / monthlyBudget;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            radius: 25,
            // backgroundColor: Color(0xff115E38),
            backgroundImage: AssetImage('assets/images/Center.png'),
          ),
        ),
        leadingWidth: 60,
        // leadingPadding: 10,
        title: Text(
          'Smart Spend',
          style: TextStyle(
            color: Color(0xff115E38),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,

        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },

            icon: const CircleAvatar(
              radius: 30,
              // dont forget to add image in assets and pubspec.yaml
              backgroundImage: NetworkImage(
                'https://www.pngplay.com/wp-content/uploads/12/User-Avatar-Profile-PNG-Free-File-Download.png',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // container for monthly spending
              // container 1
              SizedBox(height: 15),
              CustomCard(
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
                      monthlySpending.toStringAsFixed(2),
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
              SizedBox(height: 10),
              // container for monthly budget
              // container 2
              CustomCard(
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
                      monthlyBudget.toStringAsFixed(0),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
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

              SizedBox(height: 10),
              // container for spending trend
              // container 3
              CustomCard(
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      monthlyBudget.toStringAsFixed(0),
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
      ),
    );
  }
}
