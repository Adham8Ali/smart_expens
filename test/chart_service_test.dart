import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expens/models/expense_model.dart';
import 'package:smart_expens/services/chart_service.dart';

void main() {
  group('ChartService Tests', () {
    const chartService = ChartService();
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 1);

    test('categoryDisplayName returns correct display names', () {
      expect(ChartService.categoryDisplayName('food'), 'Food & Dining');
      expect(ChartService.categoryDisplayName('shopping'), 'Shopping');
      expect(ChartService.categoryDisplayName('transport'), 'Transport');
      expect(ChartService.categoryDisplayName('bills'), 'Bills');
      expect(ChartService.categoryDisplayName('drink'), 'Drink');
      expect(ChartService.categoryDisplayName('health'), 'Health');
      expect(
        ChartService.categoryDisplayName('entertainment'),
        'Entertainment',
      );
      expect(
        ChartService.categoryDisplayName('unknown_category'),
        'Unknown Category',
      );
      expect(ChartService.categoryDisplayName('custom'), 'Custom');
    });

    test('currentMonthTotal sums current month only', () {
      final expenses = [
        ExpenseModel(
          id: '1',
          uid: 'user1',
          amount: 100.0,
          categoryId: 'food',
          date: now,
          createdAt: now,
        ),
        ExpenseModel(
          id: '2',
          uid: 'user1',
          amount: 50.0,
          categoryId: 'shopping',
          date: now,
          createdAt: now,
        ),
        ExpenseModel(
          id: '3',
          uid: 'user1',
          amount: 200.0,
          categoryId: 'food',
          date: lastMonth,
          createdAt: lastMonth,
        ),
      ];

      expect(chartService.currentMonthTotal(expenses), 150.0);
    });

    test('lastMonthTotal sums last month only', () {
      final expenses = [
        ExpenseModel(
          id: '1',
          uid: 'user1',
          amount: 100.0,
          categoryId: 'food',
          date: now,
          createdAt: now,
        ),
        ExpenseModel(
          id: '2',
          uid: 'user1',
          amount: 150.0,
          categoryId: 'shopping',
          date: lastMonth,
          createdAt: lastMonth,
        ),
        ExpenseModel(
          id: '3',
          uid: 'user1',
          amount: 50.0,
          categoryId: 'food',
          date: lastMonth,
          createdAt: lastMonth,
        ),
        ExpenseModel(
          id: '4',
          uid: 'user1',
          amount: 200.0,
          categoryId: 'food',
          date: twoMonthsAgo,
          createdAt: twoMonthsAgo,
        ),
      ];

      expect(chartService.lastMonthTotal(expenses), 200.0);
    });

    test('biggestSpendingCategory finds top category and MoM comparison', () {
      final expenses = [
        // Current month
        ExpenseModel(
          id: '1',
          uid: 'user1',
          amount: 500.0, // Food = 500
          categoryId: 'food',
          date: now,
          createdAt: now,
        ),
        ExpenseModel(
          id: '2',
          uid: 'user1',
          amount: 300.0, // Shopping = 300
          categoryId: 'shopping',
          date: now,
          createdAt: now,
        ),
        // Last month
        ExpenseModel(
          id: '3',
          uid: 'user1',
          amount: 400.0, // Last month Food = 400
          categoryId: 'food',
          date: lastMonth,
          createdAt: lastMonth,
        ),
        ExpenseModel(
          id: '4',
          uid: 'user1',
          amount: 600.0, // Last month Shopping = 600 (not top this month)
          categoryId: 'shopping',
          date: lastMonth,
          createdAt: lastMonth,
        ),
      ];

      final biggest = chartService.biggestSpendingCategory(expenses);
      expect(biggest, isNotNull);
      expect(biggest!.categoryId, 'food');
      expect(biggest.categoryDisplayName, 'Food & Dining');
      expect(biggest.totalAmount, 500.0);
      // Food MoM: (500 - 400) / 400 = +25%
      expect(biggest.changePercent, 25.0);
      expect(biggest.changeText, '+25.0%');
      expect(biggest.isIncrease, true);
    });

    test(
      'biggestSpendingCategory returns null when no current month expenses',
      () {
        final expenses = [
          ExpenseModel(
            id: '1',
            uid: 'user1',
            amount: 500.0,
            categoryId: 'food',
            date: lastMonth,
            createdAt: lastMonth,
          ),
        ];
        expect(chartService.biggestSpendingCategory(expenses), isNull);
      },
    );

    test(
      'averageMonthlySpending calculates correct mean over active months',
      () {
        final expenses = [
          ExpenseModel(
            id: '1',
            uid: 'user1',
            amount: 100.0,
            categoryId: 'food',
            date: now,
            createdAt: now,
          ),
          ExpenseModel(
            id: '2',
            uid: 'user1',
            amount: 200.0,
            categoryId: 'shopping',
            date: now,
            createdAt: now,
          ), // Now: 300.0 total
          ExpenseModel(
            id: '3',
            uid: 'user1',
            amount: 150.0,
            categoryId: 'food',
            date: lastMonth,
            createdAt: lastMonth,
          ), // Last Month: 150.0 total
        ];

        // Average = (300 + 150) / 2 = 225.0
        expect(chartService.averageMonthlySpending(expenses), 225.0);
      },
    );

    test('averageMonthlySpending returns 0.0 when empty', () {
      expect(chartService.averageMonthlySpending([]), 0.0);
    });

    test('remainingBalanceComparison calculates correct MoM balance', () {
      final expenses = [
        // Current month total: 300.0
        ExpenseModel(
          id: '1',
          uid: 'user1',
          amount: 300.0,
          categoryId: 'food',
          date: now,
          createdAt: now,
        ),
        // Last month total: 500.0
        ExpenseModel(
          id: '2',
          uid: 'user1',
          amount: 500.0,
          categoryId: 'food',
          date: lastMonth,
          createdAt: lastMonth,
        ),
      ];

      final budget = 1000.0;
      // Current remaining = 1000 - 300 = 700.0
      // Last remaining = 1000 - 500 = 500.0
      // Change percent = (700 - 500) / 500 = +40%
      final comparison = chartService.remainingBalanceComparison(
        expenses,
        budget,
      );
      expect(comparison.currentMonthTotal, 700.0);
      expect(comparison.lastMonthTotal, 500.0);
      expect(comparison.changePercent, 40.0);
      expect(comparison.changeText, '+40.0%');
      expect(comparison.isIncrease, true);
    });
  });
}
