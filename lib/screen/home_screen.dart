import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/screen/account_screen.dart';
import 'package:smart_expens/widget/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.monthlyBudget});

  final double monthlyBudget;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    // Define monthly spending and budget as variables for calculation
    double monthlySpending = 3000;
    double monthlyBudget = widget.monthlyBudget;
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

            icon: CircleAvatar(
              radius: 30,
              backgroundImage: currentUser?.image != null
                  ? NetworkImage(currentUser!.image!)
                  : null,
              child: currentUser?.image == null
                  ? Icon(Icons.person, size: 30)
                  : null,
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
                // height: 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Monthly Spending',
                          style: TextStyle(
                            fontSize: 21,
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Spacer(),

                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            size: 30,
                            Icons.account_balance_wallet,
                            color: Color(0xff115E38),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),
                    // shoud edit
                    Text(
                      monthlySpending.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xff115E38),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "+12% ",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("vs last month"),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // container for monthly budget
              // container 2
              CustomCard(
                height: 210,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: TextStyle(
                        fontSize: 21,
                        color: Color(0xff6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8),

                    // shoud edit
                    Text(
                      monthlyBudget.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xff115E38),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Used",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          "${(progress * 100).toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                      "Remaining ${monthlyBudget - monthlySpending} ",
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
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Spending Trend",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        /// Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: const Row(
                            children: [
                              Text("Last 6 Months"),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Chart
                    SizedBox(
                      height: 280,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    "JAN",
                                    "FEB",
                                    "MAR",
                                    "APR",
                                    "MAY",
                                    "JUN",
                                    "JUL",
                                    "AUG",
                                  ];
                                  if (value.toInt() < 0 ||
                                      value.toInt() >= months.length) {
                                    return const Text("");
                                  }
                                  return Text(months[value.toInt()]);
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 10),
                                FlSpot(1, 20),
                                FlSpot(2, 45),
                                FlSpot(3, 30),
                                FlSpot(4, 55),
                                FlSpot(5, 65),
                                FlSpot(6, 85),
                                FlSpot(7, 75),
                              ],
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
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
