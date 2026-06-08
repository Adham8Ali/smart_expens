import 'package:smart_expens/models/expense_model.dart';

/// Maps user spending data to the external analysis API request format.
///
/// API endpoint: POST /analyze
/// The API expects `salary` (monthly budget) and per-category totals.
class AnalysisRequestModel {
  final double salary;
  final double food;
  final double drink;
  final double shopping;
  final double transport;
  final double bills;
  final double health;
  final double entertainment;

  const AnalysisRequestModel({
    required this.salary,
    required this.food,
    required this.drink,
    required this.shopping,
    required this.transport,
    required this.bills,
    required this.health,
    required this.entertainment,
  });

  /// Transforms Firestore expense data + budget into the API request format.
  factory AnalysisRequestModel.fromExpenses({
    required double monthlyBudget,
    required List<ExpenseModel> expenses,
  }) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
    }

    return AnalysisRequestModel(
      salary: monthlyBudget,
      food: categoryTotals['food'] ?? 0.0,
      drink: categoryTotals['drink'] ?? 0.0,
      shopping: categoryTotals['shopping'] ?? 0.0,
      transport: categoryTotals['transport'] ?? 0.0,
      bills: categoryTotals['bills'] ?? 0.0,
      health: categoryTotals['health'] ?? 0.0,
      entertainment: categoryTotals['entertainment'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salary': salary,
      'food': food,
      'drink': drink,
      'shopping': shopping,
      'transport': transport,
      'bills': bills,
      'health': health,
      'entertainment': entertainment,
    };
  }

  @override
  String toString() =>
      'AnalysisRequestModel(salary: $salary, food: $food, drink: $drink, '
      'shopping: $shopping, transport: $transport, bills: $bills, '
      'health: $health, entertainment: $entertainment)';
}
