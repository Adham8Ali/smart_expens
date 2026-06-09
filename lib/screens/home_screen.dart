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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const ChartService _chartService = ChartService();

  /// Dropdown options and their month counts — same as Reports screen
  static const _dropdownOptions = {
    'Last Month': 1,
    'Last 2 Months': 2,
    'Last 3 Months': 3,
    'Last 6 Months': 6,
  };

  String _selectedRange = 'Last 6 Months';

  int get _monthCount => _dropdownOptions[_selectedRange]!;

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

    // Chart data — same ChartService and logic as Reports
    final chartData = _chartService.getChartData(
      expenseProvider.expenses,
      _monthCount,
    );

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
              backgroundImage: currentUser?.profileImage != null
                  ? NetworkImage(currentUser!.profileImage!)
                  : null,
              child: currentUser?.profileImage == null
                  ? Icon(Icons.person, size: 55)
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
                            size: 50,
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

              // Container 3 — Spending Trend Chart (same style as Reports)
              CustomCard(
                height: 420,
                child: Column(
                  children: [
                    // Header with functional Dropdown
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
                        _buildDropdown(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Chart — same smooth line chart as Reports
                    SizedBox(
                      height: 300,
                      child: _buildSmoothLineChart(chartData),
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

  // ─── Dropdown Widget (same as Reports) ──────────────────────────────────────

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRange,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _dropdownOptions.keys
              .map(
                (label) => DropdownMenuItem(
                  value: label,
                  child: Text(label, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedRange = value);
          },
        ),
      ),
    );
  }

  // ─── Smooth Line Chart (same style as Reports) ─────────────────────────────

  Widget _buildSmoothLineChart(List<ChartDataPoint> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = List.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i].value),
    );

    final maxVal = spots.map((s) => s.y).reduce(max);
    final chartMaxY = max(100.0, maxVal * 1.2);

    // For daily view (Last Month), show every 5th day label
    final isDailyView = _monthCount == 1;

    return LineChart(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: chartMaxY / 5,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: chartMaxY / 5,
              reservedSize: 45,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 11, color: Color(0xff6B7280)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const Text('');

                if (isDailyView) {
                  // Show label every 5th day
                  if ((idx + 1) % 5 != 0 && idx != 0) return const Text('');
                  return Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xff6B7280),
                    ),
                  );
                }

                return Text(
                  data[idx].label.split(' ').first,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xff6B7280),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.black, width: 2),
            bottom: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        minX: 0,
        maxX: spots.length - 1,
        minY: 0,
        maxY: chartMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            color: const Color(0xff115E38),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: !isDailyView, // Hide dots on daily view (too many points)
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 2.5,
                    strokeColor: const Color(0xff115E38),
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xff115E38).withAlpha(60),
                  const Color(0xff115E38).withAlpha(5),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((ts) {
              final idx = ts.x.toInt();
              final label = idx < data.length ? data[idx].label : '';
              return LineTooltipItem(
                '$label\n\$${ts.y.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((i) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: const Color(0xff115E38).withAlpha(80),
                  strokeWidth: 2,
                  dashArray: [4, 4],
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 6,
                        color: const Color(0xff115E38),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
