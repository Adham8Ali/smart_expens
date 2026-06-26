import 'package:smart_expens/models/expense_model.dart';

/// Maps user spending data to the external analysis API request format.
///
/// API endpoint: POST /analyze
/// The API expects per-category totals for generating recommendations.
class AnalysisRequestModel {
  final double salary;
  final double food;
  final double drink;
  final double shopping;
  final double transport;
  final double bills;
  final double health;
  final double entertainment;
  final double others; // تمت إضافة others

  const AnalysisRequestModel({
    required this.salary,
    required this.food,
    required this.drink,
    required this.shopping,
    required this.transport,
    required this.bills,
    required this.health,
    required this.entertainment,
    required this.others, // تمت إضافة others
  });

  /// Transforms Firestore expense data into the API request format.
  factory AnalysisRequestModel.fromExpenses({
    required List<ExpenseModel> expenses,
    required double salary,
  }) {
    final now = DateTime.now();
    final categoryTotals = <String, double>{};
    
    for (final expense in expenses) {
      if (expense.date.year == now.year && expense.date.month == now.month) {
        // تحويل كل التصنيفات إلى حروف صغيرة لتوحيد قراءة بيانات الويب والفلاتر معاً
        final cat = expense.categoryId.toLowerCase();
        categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + expense.amount;
      }
    }

    // ملاحظة: الويب يرسل Dining بداخل الـ Food، لذا سنجمعهما هنا كإجراء احترازي
    final foodTotal = (categoryTotals['food'] ?? 0.0) + (categoryTotals['dining'] ?? 0.0);

    return AnalysisRequestModel(
      salary: salary,
      food: foodTotal,
      drink: categoryTotals['drink'] ?? 0.0,
      shopping: categoryTotals['shopping'] ?? 0.0,
      transport: categoryTotals['transportation'] ?? (categoryTotals['transport'] ?? 0.0), // دعم transportation و transport
      bills: categoryTotals['bills'] ?? 0.0,
      health: categoryTotals['health'] ?? 0.0,
      entertainment: categoryTotals['entertainment'] ?? 0.0,
      others: categoryTotals['others'] ?? 0.0, // تمت إضافة others
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
      'others': others, // تمت إضافة others
    };
  }

  @override
  String toString() =>
      'AnalysisRequestModel(salary: $salary, food: $food, drink: $drink, '
      'shopping: $shopping, transport: $transport, bills: $bills, '
      'health: $health, entertainment: $entertainment, others: $others)';
}