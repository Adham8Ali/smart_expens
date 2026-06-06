import 'package:flutter/material.dart';
import 'package:smart_expens/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
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

    // Summary values
    final currentMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final currentMonthTotal = expenseProvider.expenses
        .where(
          (e) =>
              e.date.year == currentMonth.year &&
              e.date.month == currentMonth.month,
        )
        .fold(0.0, (s, e) => s + e.amount);
    final lastMonthTotal = expenseProvider.expenses
        .where(
          (e) =>
              e.date.year == lastMonth.year && e.date.month == lastMonth.month,
        )
        .fold(0.0, (s, e) => s + e.amount);

    final currentMonthTxCount = expenseProvider.expenses
        .where(
          (e) =>
              e.date.year == currentMonth.year &&
              e.date.month == currentMonth.month,
        )
        .length;

    // transaction counts omitted (not used for current badges)

    final currentDayOfMonth = now.day;
    final dailyAverage = currentDayOfMonth == 0
        ? 0.0
        : currentMonthTotal / currentDayOfMonth;

    final spendingChangePercent = lastMonthTotal == 0
        ? 0.0
        : ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100.0;
    final spendingChangeText = lastMonthTotal == 0
        ? '+0%'
        : '${spendingChangePercent >= 0 ? '+' : ''}${spendingChangePercent.toStringAsFixed(1)}%';
    final spendingChangeColor = spendingChangePercent >= 0
        ? Colors.green
        : Colors.red;

    // transaction-change values kept if needed later

    // Category-specific (Food & Dining) summary
    final categoryId = 'food';
    final categoryLabel = 'Food & Dining';
    final foodCurrentTotal = expenseProvider.expenses
        .where(
          (e) =>
              e.categoryId == categoryId &&
              e.date.year == currentMonth.year &&
              e.date.month == currentMonth.month,
        )
        .fold(0.0, (s, e) => s + e.amount);
    final foodLastTotal = expenseProvider.expenses
        .where(
          (e) =>
              e.categoryId == categoryId &&
              e.date.year == lastMonth.year &&
              e.date.month == lastMonth.month,
        )
        .fold(0.0, (s, e) => s + e.amount);
    final foodChangePercent = foodLastTotal == 0
        ? 0.0
        : ((foodCurrentTotal - foodLastTotal) / foodLastTotal) * 100.0;
    final foodChangeText = foodLastTotal == 0
        ? '+0%'
        : '${foodChangePercent >= 0 ? '+' : ''}${foodChangePercent.toStringAsFixed(1)}%';
    final foodChangeColor = foodChangePercent >= 0 ? Colors.green : Colors.red;
    final foodBadgeText = '$foodChangeText vs last month';

    final spendingBadgeText =
        '$spendingChangeText ${spendingChangePercent >= 0 ? 'increase' : 'decrease'}';

    final formatter = NumberFormat.decimalPattern();

    // Target comparison (daily) based on user's persisted monthly budget
    final userProvider = Provider.of<UserProvider>(context);
    final monthlyBudget = userProvider.currentUser?.monthlyBudget ?? 0.0;
    final targetDaily = monthlyBudget > 0 ? monthlyBudget / 30.0 : 0.0;
    final targetDiffPercent = (targetDaily == 0)
        ? 0.0
        : ((dailyAverage - targetDaily) / targetDaily) * 100.0;
    final targetBadgeText = (targetDaily == 0)
        ? '+0% vs target'
        : '${targetDiffPercent >= 0 ? '+' : ''}${targetDiffPercent.toStringAsFixed(0)}% vs target';
    final targetBadgeColor = targetDiffPercent >= 0
        ? Colors.green
        : Colors.orange;

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      //   backgroundColor: Colors.white,
      //   scrolledUnderElevation: 0,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    circleBtn(Icons.arrow_back),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Text(
                        "Reports",

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                CustomCard(
                  height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Daily Average",
                            style: TextStyle(
                              fontSize: 21,
                              color: Color(0xff6B7280),

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              size: 30,
                              Icons.shopping_cart,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        formatter.format(dailyAverage.round()),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
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
                              color: foodChangeColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              foodBadgeText,
                              style: TextStyle(color: foodChangeColor),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(categoryLabel),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomCard(
                  height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Savings",
                            style: TextStyle(
                              fontSize: 21,
                              color: Color(0xff6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(Icons.savings, color: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        formatter.format(currentMonthTotal.round()),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
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
                              spendingBadgeText,
                              style: TextStyle(color: spendingChangeColor),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("vs Last Month"),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomCard(
                  height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Savings",
                            style: TextStyle(
                              fontSize: 21,
                              color: Color(0xff6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              size: 30,
                              Icons.calendar_month,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        formatter.format(currentMonthTxCount),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
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
                              color: targetBadgeColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              targetBadgeText,
                              style: TextStyle(color: targetBadgeColor),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("Per Day"),
                        ],
                      ),
                    ],
                  ),
                ),
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
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget circleBtn(IconData icon, [double size = 50]) {
  return Container(
    height: size,
    width: size,

    decoration: BoxDecoration(
      shape: BoxShape.circle,

      border: Border.all(color: Colors.grey.shade300),
    ),

    child: Icon(icon),
  );
}
