import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/budget_provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'package:smart_expens/screens/account_screen.dart';
import 'package:smart_expens/services/chart_service.dart';
import 'package:smart_expens/widgets/budget_progress_widget.dart';
import 'package:smart_expens/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const ChartService _chartService = ChartService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);

    final double monthlyBudget = budgetProvider.monthlyBudget;
    final double currentSpending = expenseProvider.currentMonthSpending;
    final double remainingBudget = (monthlyBudget - currentSpending).clamp(
      0,
      double.infinity,
    );

    // Shared analytics — same source as Reports screen
    final comparison = _chartService.monthOverMonth(expenseProvider.expenses);
    final spendingChangeColor = comparison.isIncrease
        ? Colors.red
        : Colors.green;

    // Chart data for last 6 months — same ChartService as Reports
    final chartData = _chartService.getChartData(expenseProvider.expenses, 6);
    final List<FlSpot> spots = List.generate(
      chartData.length,
      (i) => FlSpot(i.toDouble(), chartData[i].value),
    );

    final chartMaxY = (spots.isEmpty)
        ? 100.0
        : max(100.0, spots.map((s) => s.y).reduce(max) * 1.2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/Center.png'),
          ),
        ),
        leadingWidth: 60,
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
              // Container 1 — Monthly Spending
              SizedBox(height: 15),
              CustomCard(
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
                    Text(
                      '\$${currentSpending.toStringAsFixed(2)}',
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
                            color: spendingChangeColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${comparison.changeText} ',
                            style: TextStyle(color: spendingChangeColor),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('vs last month'),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Container 2 — Monthly Budget with live data
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Budget',
                          style: TextStyle(
                            fontSize: 21,
                            color: Color(0xff6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '\$${remainingBudget.toStringAsFixed(0)} left',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xff6B7280),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$${monthlyBudget.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xff115E38),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Reusable Budget Progress Widget
                    BudgetProgressWidget(
                      monthlyBudget: monthlyBudget,
                      currentSpending: currentSpending,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              // Container 3 — Spending Trend Chart
              CustomCard(
                height: 400,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Spending Trend',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                              Text('Last 6 Months'),
                              Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Chart
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
                                  if (idx < 0 || idx >= chartData.length) {
                                    return const Text('');
                                  }
                                  return Text(
                                    chartData[idx].label.split(' ').first,
                                    style: const TextStyle(fontSize: 11),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
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
                          maxX: spots.isEmpty ? 5 : spots.length - 1,
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
                              getTooltipItems: (touchedSpots) =>
                                  touchedSpots.map((ts) {
                                    final idx = ts.x.toInt();
                                    final label = idx < chartData.length
                                        ? chartData[idx].label
                                        : '';
                                    return LineTooltipItem(
                                      '$label: \$${ts.y.toStringAsFixed(2)}',
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
