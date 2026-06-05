import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expens/models/category_model.dart';
import 'package:smart_expens/models/expense_model.dart';
import 'package:smart_expens/providers/expense_provider.dart';

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

  /// Filter & sort the live provider list on-the-fly
  List<ExpenseModel> _applyFilters(List<ExpenseModel> source) {
    List<ExpenseModel> result = List.from(source);

    // SEARCH by categoryId name
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      result = result.where((e) {
        final catName = _categoryName(e.categoryId).toLowerCase();
        return catName.contains(query);
      }).toList();
    }

    // CATEGORY filter
    if (selectedCategoryId != null) {
      result = result.where((e) => e.categoryId == selectedCategoryId).toList();
    }

    // MIN amount
    if (minController.text.isNotEmpty) {
      final min = double.tryParse(minController.text);
      if (min != null) result = result.where((e) => e.amount >= min).toList();
    }

    // MAX amount
    if (maxController.text.isNotEmpty) {
      final max = double.tryParse(maxController.text);
      if (max != null) result = result.where((e) => e.amount <= max).toList();
    }

    // SORT
    if (sortType == "high") {
      result.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (sortType == "low") {
      result.sort((a, b) => a.amount.compareTo(b.amount));
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
      'other': Colors.grey,
    };
    return colors[id] ?? Colors.grey;
  }

  /// RESET
  void resetFilter() {
    setState(() {
      searchController.clear();
      minController.clear();
      maxController.clear();
      selectedCategoryId = null;
      sortType = "default";
    });
  }

  /// SORT SHEET
  void showSort() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sort By",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text("Highest Amount"),
                onTap: () {
                  setState(() => sortType = "high");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Lowest Amount"),
                onTap: () {
                  setState(() => sortType = "low");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Default (Newest First)"),
                onTap: () {
                  setState(() => sortType = "default");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 Listen to the real ExpenseProvider
    final expenseProvider = context.watch<ExpenseProvider>();
    final allExpenses = expenseProvider.expenses;
    final isLoading = expenseProvider.isLoading;
    final errorMsg = expenseProvider.errorMessage;

    final filtered = _applyFilters(allExpenses.toList());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMsg != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 12),
                          Text(errorMsg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        /// HEADER
                        Row(
                          children: [
                            circleBtn(Icons.receipt_long),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Text(
                                "Expense List",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// SEARCH
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
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            topBtn(Icons.filter_alt, () {
                              setState(() => showFilters = !showFilters);
                            }),
                            const SizedBox(width: 10),
                            topBtn(Icons.sort, showSort),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// FILTER PANEL
                        if (showFilters)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.filter_alt, color: green),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Filter Expenses",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: green,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(
                                          () => showFilters = false),
                                      child: circleBtn(Icons.close, 42),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                /// MIN MAX
                                Row(
                                  children: [
                                    Expanded(
                                        child:
                                            field("Min Amount", minController)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child:
                                            field("Max Amount", maxController)),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                /// CATEGORY DROPDOWN from real predefined list
                                DropdownButtonFormField<String>(
                                  initialValue: selectedCategoryId,
                                  decoration: InputDecoration(
                                    hintText: "Category",
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                        value: null,
                                        child: Text("All Categories")),
                                    ...CategoryModel.predefined.map(
                                      (cat) => DropdownMenuItem(
                                          value: cat.id,
                                          child: Text(cat.name)),
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      setState(() => selectedCategoryId = value),
                                ),

                                const SizedBox(height: 22),

                                /// BUTTONS
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: resetFilter,
                                        child: button(
                                            "Reset", Colors.white, Colors.black),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {}),
                                        child: button(
                                            "Apply", green, Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 25),

                        /// TABLE
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width - 40,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              border:
                                  Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                /// TABLE HEADER
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: green,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(25),
                                      topRight: Radius.circular(25),
                                    ),
                                  ),
                                  child: const Row(
                                    children: [
                                      SizedBox(
                                          width: 90,
                                          child: Text("Date", style: _head)),
                                      SizedBox(
                                          width: 90,
                                          child:
                                              Text("Amount", style: _head)),
                                      SizedBox(
                                          width: 110,
                                          child: Text("Category",
                                              style: _head)),
                                      SizedBox(
                                        width: 90,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text("Note", style: _head),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// EMPTY STATE
                                if (filtered.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(Icons.inbox_outlined,
                                            size: 56,
                                            color: Colors.grey.shade400),
                                        const SizedBox(height: 12),
                                        Text(
                                          allExpenses.isEmpty
                                              ? "No expenses yet.\nTap + to add your first one!"
                                              : "No expenses match your filters.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),

                                /// DATA ROWS
                                ...filtered.map(
                                  (e) => Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            "${e.date.day}/${e.date.month}/${e.date.year}",
                                            style: const TextStyle(
                                                fontSize: 13),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            "\$${e.amount.toStringAsFixed(2)}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 110,
                                          child: Text(
                                            _categoryName(e.categoryId),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  _categoryColor(e.categoryId),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              e.note ?? '-',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color:
                                                      Colors.grey.shade600,
                                                  fontSize: 12),
                                            ),
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

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  /// TOP BUTTON
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

  /// FIELD
  Widget field(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  /// BUTTON
  Widget button(String text, Color bg, Color textColor) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: bg == Colors.white ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// CIRCLE BUTTON
  Widget circleBtn(IconData icon, [double size = 50]) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon),
    );
  }
}

const _head = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
