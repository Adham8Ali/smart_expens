import 'package:flutter/material.dart';
import 'package:smart_expens/core/circleBtn.dart';
import 'package:smart_expens/widgets/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/budget_provider.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'package:smart_expens/providers/analysis_provider.dart';
import 'package:smart_expens/services/chart_service.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const ChartService _chartService = ChartService();

  /// Dropdown options and their month counts
  static const _dropdownOptions = {
    'Last Month': 1,
    'Last 2 Months': 2,
    'Last 3 Months': 3,
    'Last 6 Months': 6,
  };

  String _selectedRange = 'Last Month';

  int get _monthCount => _dropdownOptions[_selectedRange]!;

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final analysisProvider = Provider.of<AnalysisProvider>(context);
    final expenses = expenseProvider.expenses;

    // ─── Biggest Spending Card data ──────────────────────────────────────────
    final biggestSpending = _chartService.biggestSpendingCategory(expenses);

    // ─── Remaining Balance Card data ─────────────────────────────────────────
    final monthlyBudget = budgetProvider.monthlyBudget;
    final balanceComparison = _chartService.remainingBalanceComparison(
      expenses,
      monthlyBudget,
    );
    final remainingBalance = balanceComparison.currentMonthTotal;
    final balanceChangeColor = balanceComparison.isIncrease
        ? Colors.green
        : Colors.red;
    final balanceBadgeText = '${balanceComparison.changeText} vs last month';

    // ─── Average Spending Card data ──────────────────────────────────────────
    final avgMonthly = _chartService.averageMonthlySpending(expenses);
    final avgVsBudgetPercent = monthlyBudget > 0
        ? ((avgMonthly - monthlyBudget) / monthlyBudget) * 100.0
        : 0.0;
    final avgBadgeText = monthlyBudget <= 0
        ? '+0% vs target'
        : '${avgVsBudgetPercent >= 0 ? '+' : ''}${avgVsBudgetPercent.toStringAsFixed(0)}% vs target';
    final avgBadgeColor = avgVsBudgetPercent >= 0 ? Colors.red : Colors.green;

    final formatter = NumberFormat.decimalPattern();

    // Chart data from shared ChartService (Feature 2)
    final chartData = _chartService.getChartData(expenses, _monthCount);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    circleBtn(Icons.file_copy_sharp),
                    const SizedBox(width: 15),

                    const Expanded(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Biggest Spending Card — dynamic highest category
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Biggest Spending',
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
                        biggestSpending != null
                            ? formatter.format(
                                biggestSpending.totalAmount.round(),
                              )
                            : '0',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
                        ),
                      ),
                      SizedBox(height: 8),
                      if (biggestSpending != null) ...[
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (biggestSpending.isIncrease
                                              ? Colors.red
                                              : Colors.green)
                                          .withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${biggestSpending.changeText} vs last month',
                                  style: TextStyle(
                                    color: biggestSpending.isIncrease
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(biggestSpending.categoryDisplayName),
                          ],
                        ),
                      ] else
                        Text(
                          'No spending data',
                          style: TextStyle(color: Color(0xff6B7280)),
                        ),
                    ],
                  ),
                ),

                // Remaining Balance Card
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining Balance',
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
                        formatter.format(remainingBalance.round()),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: balanceChangeColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                balanceBadgeText,
                                style: TextStyle(color: balanceChangeColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Per Month'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Average Spending Card
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Average Spending',
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
                        formatter.format(avgMonthly.round()),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: avgBadgeColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                avgBadgeText,
                                style: TextStyle(color: avgBadgeColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Per month'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Spending Trend Chart with Dropdown
                CustomCard(
                  height: 420,
                  child: Column(
                    children: [
                      // Header with Dropdown
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

                      // Dynamic Smooth Line Chart (Feature 3)
                      SizedBox(
                        height: 300,
                        child: _buildSmoothLineChart(chartData),
                      ),
                    ],
                  ),
                ),

                // AI Analysis Card — button only (Feature 5: results in bottom sheet)
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'AI Spending Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.auto_awesome, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get AI-powered insights about your spending habits',
                        style: TextStyle(
                          color: Color(0xff6B7280),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Analyze Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff115E38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: analysisProvider.isLoading
                              ? null
                              : () => _triggerAnalysis(
                                  analysisProvider,
                                  expenseProvider,
                                  monthlyBudget,
                                ),
                          icon: analysisProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.analytics,
                                  color: Colors.white,
                                ),
                          label: Text(
                            analysisProvider.isLoading
                                ? 'Analyzing...'
                                : 'Analyze My Spending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      // Error inline
                      if (analysisProvider.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    analysisProvider.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Dropdown Widget ──────────────────────────────────────────────────────

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

  // ─── Smooth Line Chart (Feature 3) ────────────────────────────────────────

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

  // ─── AI Analysis Trigger (Feature 5: opens bottom sheet) ──────────────────

  void _triggerAnalysis(
    AnalysisProvider analysisProvider,
    ExpenseProvider expenseProvider,
    double monthlyBudget,
  ) {
    analysisProvider
        .fetchAnalysis(
          expenses: expenseProvider.expenses,
          salary: monthlyBudget,
        )
        .then((_) {
          if (!mounted) return;
          if (analysisProvider.hasResult) {
            _showAnalysisBottomSheet(analysisProvider);
          }
        });
  }

  /// Feature 5: AI results in a modal bottom sheet
  void _showAnalysisBottomSheet(AnalysisProvider provider) {
    final result = provider.analysisResult!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // AI Icon
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(
                              0xff115E38,
                            ).withAlpha(30),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Color(0xff115E38),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          const Text(
                            'AI Spending Analysis',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff115E38),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on your current month data',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Divider
                          Divider(color: Colors.green.shade200, thickness: 1),

                          const SizedBox(height: 16),

                          // Recommendation entries
                          ...result.insights.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: const Color(0xff115E38),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '${_formatKey(entry.key)}: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          TextSpan(text: '${entry.value}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            'Updated ${DateFormat('MMM d, yyyy h:mm a').format(result.fetchedAt)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Close Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff115E38),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'[_]'), (m) => ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  Widget _circleBtn(IconData icon, [double size = 50]) {
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
}
