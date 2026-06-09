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

/// Result of the biggest spending category analysis.
class BiggestSpending {
  /// The category ID (e.g. 'food').
  final String categoryId;

  /// Human-readable display name (e.g. 'Food & Dining').
  final String categoryDisplayName;

  /// Total amount spent in this category for the current month.
  final double totalAmount;

  /// Percentage change vs the same category last month.
  final double changePercent;

  /// Formatted change text (e.g. '+12.0%').
  final String changeText;

  /// True if spending increased vs last month.
  final bool isIncrease;

  const BiggestSpending({
    required this.categoryId,
    required this.categoryDisplayName,
    required this.totalAmount,
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

  // ─── Category Display Names ───────────────────────────────────────────────

  /// Static mapping from category IDs to human-readable display names.
  static const Map<String, String> _categoryDisplayNames = {
    'food': 'Food & Dining',
    'shopping': 'Shopping',
    'transport': 'Transport',
    'bills': 'Bills',
    'drink': 'Drink',
    'health': 'Health',
    'entertainment': 'Entertainment',
  };

  /// Returns the display name for a category ID.
  /// Falls back to a title-cased version of the ID for unknown categories.
  static String categoryDisplayName(String categoryId) {
    return _categoryDisplayNames[categoryId.toLowerCase()] ??
        categoryId
            .split('_')
            .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ');
  }

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

  /// Finds the category with the highest total spending in the current month.
  ///
  /// Returns `null` if there are no expenses in the current month.
  BiggestSpending? biggestSpendingCategory(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month - 1, 1);

    // Group current month expenses by category
    final categoryTotals = <String, double>{};
    for (final e in expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        categoryTotals[e.categoryId] =
            (categoryTotals[e.categoryId] ?? 0.0) + e.amount;
      }
    }

    if (categoryTotals.isEmpty) return null;

    // Find the category with the highest total
    String topCategoryId = categoryTotals.keys.first;
    double topAmount = categoryTotals.values.first;
    for (final entry in categoryTotals.entries) {
      if (entry.value > topAmount) {
        topCategoryId = entry.key;
        topAmount = entry.value;
      }
    }

    // Compare with the same category last month
    final lastMonthAmount = expenses
        .where((e) =>
            e.categoryId == topCategoryId &&
            e.date.year == last.year &&
            e.date.month == last.month)
        .fold(0.0, (s, e) => s + e.amount);

    final percent = lastMonthAmount == 0
        ? 0.0
        : ((topAmount - lastMonthAmount) / lastMonthAmount) * 100.0;
    final text = lastMonthAmount == 0
        ? '+0%'
        : '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}%';

    return BiggestSpending(
      categoryId: topCategoryId,
      categoryDisplayName: categoryDisplayName(topCategoryId),
      totalAmount: topAmount,
      changePercent: percent,
      changeText: text,
      isIncrease: percent >= 0,
    );
  }

  /// Calculates the average monthly spending across all months with transactions.
  ///
  /// Formula: (Total Spending Across All Months) / (Number of Months with Transactions)
  /// Returns 0.0 if there are no expenses.
  double averageMonthlySpending(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return 0.0;

    // Group expenses by (year, month)
    final monthlyTotals = <String, double>{};
    for (final e in expenses) {
      final key = '${e.date.year}-${e.date.month}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0.0) + e.amount;
    }

    if (monthlyTotals.isEmpty) return 0.0;

    final totalAll = monthlyTotals.values.fold(0.0, (sum, v) => sum + v);
    return totalAll / monthlyTotals.length;
  }

  /// Computes the remaining balance comparison between current and previous month.
  ///
  /// Remaining = monthlyBudget - totalExpenses
  /// Returns a MonthComparison where currentMonthTotal = current remaining,
  /// lastMonthTotal = previous remaining.
  MonthComparison remainingBalanceComparison(
    List<ExpenseModel> expenses,
    double monthlyBudget,
  ) {
    final currentSpending = currentMonthTotal(expenses);
    final lastSpending = lastMonthTotal(expenses);

    final currentRemaining = monthlyBudget - currentSpending;
    final lastRemaining = monthlyBudget - lastSpending;

    final percent = lastRemaining == 0
        ? 0.0
        : ((currentRemaining - lastRemaining) / lastRemaining.abs()) * 100.0;
    final text = lastRemaining == 0
        ? '+0%'
        : '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}%';

    return MonthComparison(
      currentMonthTotal: currentRemaining,
      lastMonthTotal: lastRemaining,
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
