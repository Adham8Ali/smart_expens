import 'package:flutter/material.dart';

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

  String? selectedCategory;
  String sortType = "default";

  final expenses = [
    {
      "date": "Jan 15",
      "amount": 42.50,
      "category": "Food",
      "color": Colors.orange,
    },
    {
      "date": "Jan 13",
      "amount": 125.00,
      "category": "Shopping",
      "color": Colors.purple,
    },
    {
      "date": "Jan 12",
      "amount": 89.99,
      "category": "Groceries",
      "color": Colors.green,
    },
    {
      "date": "Jan 10",
      "amount": 55.00,
      "category": "Fitness",
      "color": Colors.teal,
    },
  ];

  late List<Map<String, dynamic>> filteredExpenses;

  @override
  void initState() {
    super.initState();

    filteredExpenses = List.from(expenses);
  }

  /// APPLY FILTER
  void applyFilter() {
    filteredExpenses = List.from(expenses);

    /// SEARCH
    if (searchController.text.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((e) {
        return e["category"].toString().toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

    /// CATEGORY
    if (selectedCategory != null) {
      filteredExpenses = filteredExpenses.where((e) {
        return e["category"] == selectedCategory;
      }).toList();
    }

    /// MIN
    if (minController.text.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((e) {
        return e["amount"] >= double.parse(minController.text);
      }).toList();
    }

    /// MAX
    if (maxController.text.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((e) {
        return e["amount"] <= double.parse(maxController.text);
      }).toList();
    }

    /// SORT
    if (sortType == "high") {
      filteredExpenses.sort((a, b) => b["amount"].compareTo(a["amount"]));
    }

    if (sortType == "low") {
      filteredExpenses.sort((a, b) => a["amount"].compareTo(b["amount"]));
    }

    setState(() {});
  }

  /// RESET
  void resetFilter() {
    searchController.clear();
    minController.clear();
    maxController.clear();

    selectedCategory = null;

    filteredExpenses = List.from(expenses);

    setState(() {});
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
                  sortType = "high";

                  applyFilter();

                  Navigator.pop(context);
                },
              ),

              ListTile(
                title: const Text("Lowest Amount"),

                onTap: () {
                  sortType = "low";

                  applyFilter();

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
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [
                  circleBtn(Icons.arrow_back),

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

                        onChanged: (_) => applyFilter(),

                        decoration: InputDecoration(
                          hintText: "Search expenses...",

                          prefixIcon: const Icon(Icons.search),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),

                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  topBtn(Icons.filter_alt, () {
                    setState(() {
                      showFilters = !showFilters;
                    });
                  }),

                  const SizedBox(width: 10),

                  topBtn(Icons.sort, showSort),
                ],
              ),

              const SizedBox(height: 25),

              /// FILTER
              if (showFilters)
                Container(
                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),

                    border: Border.all(color: Colors.grey.shade300),
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
                            onTap: () {
                              setState(() {
                                showFilters = false;
                              });
                            },

                            child: circleBtn(Icons.close, 42),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// MIN MAX
                      Row(
                        children: [
                          Expanded(child: field("Min Amount", minController)),

                          const SizedBox(width: 12),

                          Expanded(child: field("Max Amount", maxController)),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// CATEGORY
                      dropdown("Category", [
                        "Food",
                        "Shopping",
                        "Groceries",
                        "Fitness",
                      ]),

                      const SizedBox(height: 22),

                      /// BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: resetFilter,

                              child: button(
                                "Reset",
                                Colors.white,
                                Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: GestureDetector(
                              onTap: applyFilter,

                              child: button("Apply", green, Colors.white),
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
                    minWidth: MediaQuery.of(context).size.width - 40,
                  ),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),

                    border: Border.all(color: Colors.grey.shade300),
                  ),

                  child: Column(
                    children: [
                      /// HEADER
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
                              child: Text("Date", style: head),
                            ),

                            SizedBox(
                              width: 90,
                              child: Text("Amount", style: head),
                            ),

                            SizedBox(
                              width: 100,
                              child: Text("Category", style: head),
                            ),

                            SizedBox(
                              width: 90,
                              child: Align(
                                alignment: Alignment.centerRight,

                                child: Text("Actions", style: head),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// ROWS
                      ...filteredExpenses.map(
                        (e) => Container(
                          padding: const EdgeInsets.all(15),

                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),

                          child: Row(
                            children: [
                              SizedBox(
                                width: 90,

                                child: Text(e["date"].toString()),
                              ),

                              SizedBox(
                                width: 90,

                                child: Text("\$${e["amount"]}"),
                              ),

                              SizedBox(
                                width: 100,

                                child: Text(
                                  e["category"].toString(),

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    color: e["color"] as Color,

                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 90,

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,

                                  children: [
                                    actionBtn(
                                      Icons.edit,
                                      Colors.green.shade50,
                                      green,
                                    ),

                                    const SizedBox(width: 8),

                                    actionBtn(
                                      Icons.delete,
                                      Colors.orange.shade50,
                                      Colors.orange,
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

  /// DROPDOWN
  Widget dropdown(String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,

      decoration: InputDecoration(
        hintText: hint,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),

      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),

      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
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

        border: bg == Colors.white
            ? Border.all(color: Colors.grey.shade300)
            : null,
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

  /// ACTION BUTTON
  Widget actionBtn(IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),

      decoration: BoxDecoration(
        color: bg,

        borderRadius: BorderRadius.circular(10),
      ),

      child: Icon(icon, color: color, size: 20),
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

const head = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
