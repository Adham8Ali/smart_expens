import 'package:flutter/material.dart';

/// Previously managed Firestore stream subscriptions for the providers.
///
/// Now that [ExpenseProvider], [BudgetProvider], and [CategoryProvider]
/// self-manage their streams via `FirebaseAuth.authStateChanges()`,
/// this widget is a simple pass-through retained for backward compatibility.
class ExpenseListener extends StatelessWidget {
  const ExpenseListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
