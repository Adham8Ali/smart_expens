import 'package:flutter/material.dart';
import 'package:smart_expens/screen/account_screen.dart';
import 'package:smart_expens/screen/expense_screen.dart';
import 'package:smart_expens/screen/home_screen.dart';
import 'package:smart_expens/screen/reports_screen.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key, required this.monthlyBudget});

  final double monthlyBudget;

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int currentIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      HomeScreen(monthlyBudget: widget.monthlyBudget),
      ReportsScreen(),
      ExpenseScreen(),
      AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: const Text('Smart Spend')),
      body: IndexedStack(index: currentIndex, children: screens),

      // زرار Add في النص
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddExpenseDialog(context);
        },
        backgroundColor: Colors.green.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            25,
          ), // يمكنك تعديل القيمة كما تشاء
        ),
        child: const Icon(Icons.add, size: 45, color: Color(0xff115E38)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 👇 البار اللي تحت
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),

          child: BottomAppBar(
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 30,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // الجزء الشمال
                  Row(
                    children: [
                      buildItem(Icons.home, "Home", 0),
                      const SizedBox(width: 30),
                      buildItem(Icons.bar_chart, "Reports", 1),
                    ],
                  ),

                  // الجزء اليمين
                  Row(
                    children: [
                      buildItem(Icons.analytics, "ُexpenses", 2),
                      const SizedBox(width: 30),
                      buildItem(Icons.account_circle, "Account", 3),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 👇 Widget للأيقونات
  Widget buildItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? const Color(0xff115E38) : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xff115E38) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

void showAddExpenseDialog(BuildContext context) {
  String? selectedCategory;
  DateTime? selectedDate;
  TextEditingController amountController = TextEditingController();

  List<String> categories = [
    "salary",
    "food",
    "drink",
    "shopping",
    "bills",
    "health",
    "entertainment",
  ];

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Add Expense",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // Amount
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedCategory = value;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // Date Picker
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        selectedDate == null
                            ? "Select Date"
                            : selectedDate.toString().split(" ")[0],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Button
                  ElevatedButton(
                    onPressed: () {
                      print("Amount: ${amountController.text}");
                      print("Category: $selectedCategory");
                      print("Date: $selectedDate");

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff115E38),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("Add"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
