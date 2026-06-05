import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/providers/category_provider.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'package:smart_expens/providers/user_provider.dart';

/// Starts and stops [ExpenseProvider] Firestore listening based on auth state.
///
/// Must wrap authenticated screens (e.g. [NavbarScreen]) so the real-time
/// stream is active before any add/update/delete calls.
class ExpenseListener extends StatefulWidget {
  const ExpenseListener({super.key, required this.child});

  final Widget child;

  @override
  State<ExpenseListener> createState() => _ExpenseListenerState();
}

class _ExpenseListenerState extends State<ExpenseListener> {
  String? _activeUid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncListener());
    context.read<UserProvider>().addListener(_syncListener);
  }

  @override
  void dispose() {
    context.read<UserProvider>().removeListener(_syncListener);
    super.dispose();
  }

  void _syncListener() {
    if (!mounted) return;

    final uid =
        context.read<UserProvider>().currentUid ??
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == _activeUid) return;

    final expenseProvider = context.read<ExpenseProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    if (uid != null && uid.isNotEmpty) {
      _activeUid = uid;
      expenseProvider.startListening(uid);
      categoryProvider.startListening(uid);
    } else {
      _activeUid = null;
      expenseProvider.stopListening();
      categoryProvider.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
