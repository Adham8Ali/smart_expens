import 'package:flutter/material.dart';

/// Reusable budget progress indicator.
///
/// The bar starts FULL when no spending and DECREASES as money is spent:
///   - progressValue = remainingBudget / monthlyBudget
///   - 100%–70% remaining → Green
///   - 70%–40% remaining → Orange
///   - 40%–0% remaining → Red
///
/// All logic is kept out of this widget — it receives pre-computed values.
class BudgetProgressWidget extends StatelessWidget {
  /// The user's set monthly budget.
  final double monthlyBudget;

  /// Total spending against the budget.
  final double currentSpending;

  /// Whether to show the remaining text below the bar.
  final bool showRemainingText;

  /// Whether to show the percentage label.
  final bool showPercentageLabel;

  const BudgetProgressWidget({
    super.key,
    required this.monthlyBudget,
    required this.currentSpending,
    this.showRemainingText = true,
    this.showPercentageLabel = true,
  });

  double get _remainingBudget =>
      (monthlyBudget - currentSpending).clamp(0, monthlyBudget);

  double get _percentageUsed =>
      monthlyBudget <= 0 ? 0.0 : (currentSpending / monthlyBudget).clamp(0, 1);

  /// Progress value: starts at 1.0 (full) and decreases toward 0.0.
  double get _percentageRemaining => 1.0 - _percentageUsed;

  Color get _progressColor {
    if (_percentageRemaining >= 0.7) return const Color(0xFF2E7D32); // Green
    if (_percentageRemaining >= 0.4) return const Color(0xFFEF6C00); // Orange
    return const Color(0xFFC62828); // Red
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPercentageLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xff6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(_percentageUsed * 100).toStringAsFixed(1)}% used',
                  style: TextStyle(
                    fontSize: 14,
                    color: _progressColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Animated progress bar — value = remaining (starts full, decreases)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: _percentageRemaining),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
              ),
            );
          },
        ),

        if (showRemainingText)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '\$${_remainingBudget.toStringAsFixed(0)} remaining',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xff6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
