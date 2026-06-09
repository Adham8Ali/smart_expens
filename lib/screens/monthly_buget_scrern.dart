import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/budget_provider.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'package:smart_expens/providers/user_provider.dart';
import 'package:smart_expens/widgets/budget_progress_widget.dart';

class MonthlyBudgetScreen extends StatefulWidget {
  const MonthlyBudgetScreen({super.key});

  @override
  State<MonthlyBudgetScreen> createState() => _MonthlyBudgetScreenState();
}

class _MonthlyBudgetScreenState extends State<MonthlyBudgetScreen> {
  final TextEditingController budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _hasInitialized = false;

  @override
  void dispose() {
    budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final double currentSpending = expenseProvider.currentMonthSpending;

    // Pre-fill budget value on first build
    if (!_hasInitialized && budgetProvider.monthlyBudget > 0) {
      budgetController.text = budgetProvider.monthlyBudget.toInt().toString();
      _hasInitialized = true;
    }

    final double budget =
        double.tryParse(
          budgetController.text.isEmpty ? '0' : budgetController.text,
        ) ??
        0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F5F5),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        title: const Text(
          'Monthly Budget',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                'Total Monthly Budget',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Budget TextField with validation
              Container(
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Center(
                  child: TextFormField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '2500',
                      errorStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a budget amount';
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null) {
                        return 'Please enter a valid number';
                      }
                      if (parsed <= 0) {
                        return 'Budget must be greater than zero';
                      }
                      if (parsed > 999999999) {
                        return 'Budget amount is too large';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Current Spending
              const Center(
                child: Text(
                  'Current Spending',
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '\$${currentSpending.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Color(0xFFEF6C00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Reusable Budget Progress Widget
              BudgetProgressWidget(
                monthlyBudget: budget,
                currentSpending: currentSpending,
                showRemainingText: false,
              ),

              const SizedBox(height: 15),

              // Percent Text
              Center(
                child: Text(
                  budget > 0
                      ? '${((currentSpending / budget) * 100).clamp(0, 100).toStringAsFixed(0)}% of budget used'
                      : '0% of budget used',
                  style: const TextStyle(fontSize: 22, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 20),

              // Error message
              if (budgetProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    budgetProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Save Button with loading state
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0E6B3E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: budgetProvider.isSaving ? null : _saveBudget,
                  icon: budgetProvider.isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    budgetProvider.isSaving ? 'Saving...' : 'Save Budget',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final uid =
        context.read<UserProvider>().currentUid ??
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not signed in. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final val = double.tryParse(budgetController.text.trim()) ?? 0.0;
    
    final budgetProvider = context.read<BudgetProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await budgetProvider.saveBudget(uid, val);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(' Budget saved successfully!'),
          backgroundColor: Color(0xff0E6B3E),
        ),
      );
      navigator.pop();
    } else {
      final error = budgetProvider.errorMessage;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to save budget'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
