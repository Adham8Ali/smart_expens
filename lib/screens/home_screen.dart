import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'package:smart_expens/screens/account_screen.dart';
import 'package:smart_expens/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final double monthlySpending = expenseProvider.totalAmount;
    final double monthlyBudget =
        Provider.of<UserProvider>(context).currentUser?.monthlyBudget ?? 0.0;
    final double progress = monthlyBudget == 0
        ? 0
        : monthlySpending / monthlyBudget;

    // Chart data for last 6 months
    final monthsCount = 6;
    final now = DateTime.now();
    final monthDates = List.generate(
      monthsCount,
      (i) => DateTime(now.year, now.month - (monthsCount - 1 - i), 1),
    );

    final List<FlSpot> spots = [];
    for (var i = 0; i < monthDates.length; i++) {
      final d = monthDates[i];
      final total = expenseProvider.expenses
          .where((e) => e.date.year == d.year && e.date.month == d.month)
          .fold(0.0, (s, e) => s + e.amount);
      spots.add(FlSpot(i.toDouble(), total));
    }

    final chartMaxY = (spots.isEmpty)
        ? 100.0
        : max(100.0, spots.map((s) => s.y).reduce(max) * 1.2);

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
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: chartMaxY / 5,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1,
                            ),
                          ),
                          extraLinesData: ExtraLinesData(
                            verticalLines: [
                              VerticalLine(
                                x: 0,
                                color: Colors.red,
                                strokeWidth: 2,
                                dashArray: [5, 5],
                              ),
                            ],
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: chartMaxY / 5,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 || idx >= monthDates.length) {
                                    return const Text("");
                                  }
                                  final labelDate = monthDates[idx];
                                  return Text(
                                    '${labelDate.month}/${labelDate.year}',
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: BorderSide(color: Colors.black, width: 2),
                              bottom: BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          minX: 0,
                          maxX: (spots.isEmpty) ? 5 : spots.length - 1,
                          minY: 0,
                          maxY: chartMaxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: const Color(0xff115E38),
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                          radius: 4,
                                          color: const Color(0xff115E38),
                                          strokeWidth: 0,
                                        ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xff115E38).withAlpha(31),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) => touchedSpots.map((
                                ts,
                              ) {
                                final d = monthDates[ts.x.toInt()];
                                return LineTooltipItem(
                                  '${d.month}/${d.year}: ${ts.y.toStringAsFixed(2)}',
                                  const TextStyle(color: Colors.white),
                                );
                              }).toList(),
                            ),
                          ),
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
