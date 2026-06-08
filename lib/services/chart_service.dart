import 'package:smart_expens/models/expense_model.dart';
import 'package:intl/intl.dart';

/// A single data point for chart rendering.
class ChartDataPoint {
  /// Label shown on the X-axis (e.g. "Day 1", "May 2026").
  final String label;

  /// Numeric value for the Y-axis.
  final double value;

  const ChartDataPoint({required this.label, required this.value});

  @override
  String toString() => 'ChartDataPoint($label: $value)';
}

/// Result of a month-over-month comparison.
class MonthComparison {
  final double currentMonthTotal;
  final double lastMonthTotal;
  final double changePercent;
  final String changeText;
  final bool isIncrease;

  const MonthComparison({
    required this.currentMonthTotal,
    required this.lastMonthTotal,
    required this.changePercent,
    required this.changeText,
    required this.isIncrease,
  });
}

/// Pure computation service for analytics and chart data.
///
/// Operates entirely on in-memory expense lists — no Firestore access.
/// Both HomeScreen and ReportsScreen consume this single source of truth.
class ChartService {
  const ChartService();

  // ─── Shared Analytics (Feature 2 + 7) ─────────────────────────────────────

  /// Current month total spending.
  double currentMonthTotal(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Last month total spending.
  double lastMonthTotal(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month - 1, 1);
    return expenses
        .where((e) => e.date.year == last.year && e.date.month == last.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Month-over-month comparison (shared between Home and Reports).
  MonthComparison monthOverMonth(List<ExpenseModel> expenses) {
    final current = currentMonthTotal(expenses);
    final last = lastMonthTotal(expenses);

    final percent =
        last == 0 ? 0.0 : ((current - last) / last) * 100.0;
    final text = last == 0
        ? '+0%'
        : '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}%';

    return MonthComparison(
      currentMonthTotal: current,
      lastMonthTotal: last,
      changePercent: percent,
      changeText: text,
      isIncrease: percent >= 0,
    );
  }

  /// Category-specific month-over-month comparison.
  MonthComparison categoryMonthOverMonth(
    List<ExpenseModel> expenses,
    String categoryId,
  ) {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month - 1, 1);

    final current = expenses
        .where((e) =>
            e.categoryId == categoryId &&
            e.date.year == now.year &&
            e.date.month == now.month)
        .fold(0.0, (s, e) => s + e.amount);

    final previous = expenses
        .where((e) =>
            e.categoryId == categoryId &&
            e.date.year == last.year &&
            e.date.month == last.month)
        .fold(0.0, (s, e) => s + e.amount);

    final percent =
        previous == 0 ? 0.0 : ((current - previous) / previous) * 100.0;
    final text = previous == 0
        ? '+0%'
        : '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}%';

    return MonthComparison(
      currentMonthTotal: current,
      lastMonthTotal: previous,
      changePercent: percent,
      changeText: text,
      isIncrease: percent >= 0,
    );
  }

  /// Daily average for the current month.
  double dailyAverage(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final total = currentMonthTotal(expenses);
    return now.day == 0 ? 0.0 : total / now.day;
  }

  /// Transaction count for the current month.
  int currentMonthTransactionCount(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .length;
  }

  // ─── Chart Data ───────────────────────────────────────────────────────────

  /// Filters expenses to those within [start, end] inclusive.
  List<ExpenseModel> filterByDateRange(
    List<ExpenseModel> expenses,
    DateTime start,
    DateTime end,
  ) {
    return expenses.where((e) {
      return !e.date.isBefore(start) && !e.date.isAfter(end);
    }).toList();
  }

  /// Groups expenses by day for a single [month].
  ///
  /// Returns one [ChartDataPoint] per day.
  /// Days with zero spending are included for a complete picture.
  List<ChartDataPoint> groupByDay(
    List<ExpenseModel> expenses,
    DateTime month,
  ) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0); // last day of month
    final daysInMonth = end.day;

    final filtered = filterByDateRange(expenses, start, end);

    // Aggregate per day
    final dailyTotals = <int, double>{};
    for (final e in filtered) {
      dailyTotals[e.date.day] = (dailyTotals[e.date.day] ?? 0.0) + e.amount;
    }

    return List.generate(daysInMonth, (i) {
      final day = i + 1;
      return ChartDataPoint(
        label: 'Day $day',
        value: dailyTotals[day] ?? 0.0,
      );
    });
  }

  /// Aggregates expenses by month for the last [monthCount] months.
  ///
  /// Returns one [ChartDataPoint] per month, ordered oldest → newest.
  List<ChartDataPoint> groupByMonth(
    List<ExpenseModel> expenses,
    int monthCount,
  ) {
    final now = DateTime.now();
    final formatter = DateFormat('MMM yyyy');
    final result = <ChartDataPoint>[];

    for (var i = monthCount - 1; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);

      final total = expenses
          .where((e) =>
              e.date.year == monthDate.year &&
              e.date.month == monthDate.month)
          .fold(0.0, (sum, e) => sum + e.amount);

      result.add(ChartDataPoint(
        label: formatter.format(monthDate),
        value: total,
      ));
    }

    return result;
  }

  /// Convenience: get chart data for the "Last N Months" dropdown.
  ///
  /// For 1 month → daily breakdown.
  /// For 2+ months → monthly aggregation.
  List<ChartDataPoint> getChartData(
    List<ExpenseModel> expenses,
    int monthCount,
  ) {
    if (monthCount == 1) {
      final now = DateTime.now();
      return groupByDay(expenses, DateTime(now.year, now.month, 1));
    }
    return groupByMonth(expenses, monthCount);
  }
}
