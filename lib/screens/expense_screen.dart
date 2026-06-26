import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/core/circleBtn.dart';
import 'package:smart_expens/models/category_model.dart';
import 'package:smart_expens/models/expense_model.dart';
import 'package:smart_expens/providers/expense_provider.dart';
import 'package:intl/intl.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final green = const Color(0xff0A6C3F);

  bool showFilters = false;

  final searchController = TextEditingController();
  final minController = TextEditingController();
  final maxController = TextEditingController();

  String? selectedCategoryId;
  String sortType = "default";

  @override
  void dispose() {
    searchController.dispose();
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

  List<ExpenseModel> _applyFilters(List<ExpenseModel> source) {
    List<ExpenseModel> result = List.from(source);

    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      result = result.where((e) {
        final catName = _categoryName(e.categoryId).toLowerCase();
        return catName.contains(query) ||
            (e.note?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (selectedCategoryId != null) {
      result = result.where((e) => e.categoryId == selectedCategoryId).toList();
    }

    if (minController.text.isNotEmpty) {
      final min = double.tryParse(minController.text);
      if (min != null) result = result.where((e) => e.amount >= min).toList();
    }
    if (maxController.text.isNotEmpty) {
      final max = double.tryParse(maxController.text);
      if (max != null) result = result.where((e) => e.amount <= max).toList();
    }

    if (sortType == "high") {
      result.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (sortType == "low") {
      result.sort((a, b) => a.amount.compareTo(b.amount));
    } else {
      result.sort((a, b) => b.date.compareTo(a.date));
    }

    return result;
  }

  String _categoryName(String id) {
    try {
      return CategoryModel.predefined.firstWhere((c) => c.id == id).name;
    } catch (_) {
      return id;
    }
  }

  Color _categoryColor(String id) {
    const colors = {
      'food': Colors.orange,
      'shopping': Colors.purple,
      'bills': Colors.green,
      'health': Colors.teal,
      'transport': Colors.blue,
      'entertainment': Colors.pink,
      'drink': Colors.cyan,
    };
    return colors[id] ?? Colors.grey;
  }

  // ====================== EDIT ======================
  void _editExpense(ExpenseModel expense) {
    final amountCtrl = TextEditingController(
      text: expense.amount.toStringAsFixed(2),
    );
    final noteCtrl = TextEditingController(text: expense.note ?? '');
    String selectedCat = expense.categoryId.toLowerCase();
    DateTime selectedDate = expense.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedCat,
                decoration: const InputDecoration(labelText: 'Category'),
                items: CategoryModel.predefined
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => selectedCat = val!,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) selectedDate = picked;
                },
              ),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter valid amount')),
                );
                return;
              }

              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final expenseProvider = context.read<ExpenseProvider>();

              final success = await expenseProvider.updateExpense(
                expense,
                uid: expense.uid,
                expenseId: expense.id,
                amount: amount,
                categoryId: selectedCat,
                date: selectedDate,
                note: noteCtrl.text.trim().isEmpty
                    ? null
                    : noteCtrl.text.trim(),
              );

              if (success) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('✅ Updated successfully')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ====================== DELETE ======================
  void _deleteExpense(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Delete \$${expense.amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final expenseProvider = context.read<ExpenseProvider>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await expenseProvider.deleteExpense(
                expense.id,
                uid: expense.uid,
                expenseId: expense.id,
              );
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('🗑️ Deleted')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final filtered = _applyFilters(expenseProvider.expenses);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: expenseProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : expenseProvider.errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    expenseProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        circleBtn(Icons.receipt_long),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "Expense List",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 55,
                            child: TextField(
                              controller: searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: "Search expenses...",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        topBtn(
                          Icons.filter_alt,
                          () => setState(() => showFilters = !showFilters),
                        ),
                        const SizedBox(width: 10),
                        topBtn(Icons.sort, _showSortBottomSheet),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==================== FILTERS ====================
                    if (showFilters)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Filters",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    selectedCategoryId = null;
                                    minController.clear();
                                    maxController.clear();
                                    setState(() {});
                                  },
                                  child: Text(
                                    "Clear All",
                                    style: TextStyle(
                                      color: green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Category Filter
                            const Text(
                              "Category",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String?>(
                              initialValue: selectedCategoryId,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: green),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text("All Categories"),
                                ),
                                ...CategoryModel.predefined.map(
                                  (cat) => DropdownMenuItem(
                                    value: cat.id,
                                    child: Text(cat.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() => selectedCategoryId = val);
                              },
                            ),
                            const SizedBox(height: 16),
                            // Amount Range Filter
                            const Text(
                              "Amount Range",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: minController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: "Min",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: maxController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      hintText: "Max",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.of(context).size.width - 32,
                            ),
                            child: Column(
                              children: [
                                // Header
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: green,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: const [
                                      SizedBox(
                                        width: 75,
                                        child: Text("Date", style: _head),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: Text("Amount", style: _head),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: Text("Category", style: _head),
                                      ),
                                      SizedBox(
                                        width: 75,
                                        child: Text(
                                          "Actions",
                                          style: _head,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (filtered.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Text(
                                      "No expenses found",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                ...filtered.map(
                                  (e) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 75,
                                          child: Text(
                                            DateFormat(
                                              'dd/MM/yy',
                                            ).format(e.date),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 75,
                                          child: Text(
                                            "\$${e.amount.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 75,
                                          child: Text(
                                            _categoryName(e.categoryId),
                                            style: TextStyle(
                                              color: _categoryColor(
                                                e.categoryId,
                                              ),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 75,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () => _editExpense(e),
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: () => _deleteExpense(e),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sort By",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text("Highest Amount"),
              trailing: sortType == "high"
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => sortType = "high");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Lowest Amount"),
              trailing: sortType == "low"
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => sortType = "low");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Newest First"),
              trailing: sortType == "default"
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() => sortType = "default");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget topBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: green),
        ),
        child: Icon(icon, color: green),
      ),
    );
  }

 
}

const _head = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
