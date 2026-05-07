import 'package:flutter/material.dart';
import 'package:smart_expens/widget/custom_card.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      //   backgroundColor: Colors.white,
      //   scrolledUnderElevation: 0,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    circleBtn(Icons.arrow_back),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Text(
                        "Reports",

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                CustomCard(
                  height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Daily Average",
                            style: TextStyle(
                              fontSize: 21,
                              color: Color(0xff6B7280),

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              size: 30,
                              Icons.shopping_cart,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "1,247",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "+12% vs last month",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("Food & Dining"),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomCard(
                  height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Savings",
                            style: TextStyle(
                              fontSize: 21,
                              color: Color(0xff6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(Icons.savings, color: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "3,892",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "+24% increase",
                              style: TextStyle(color: Color(0xff115E38)),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("vs Last Month"),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomCard(
                  height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Savings",
                            style: TextStyle(
                              fontSize: 21,
                              color: Color(0xff6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              size: 30,
                              Icons.calendar_month,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        "127",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff115E38),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "-5% vs target",
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("Per Day"),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomCard(
                  height: 400,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Spending Trend",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          /// Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: const Row(
                              children: [
                                Text("Last 6 Months"),
                                Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// Chart
                      SizedBox(
                        height: 280,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const months = [
                                      "JAN",
                                      "FEB",
                                      "MAR",
                                      "APR",
                                      "MAY",
                                      "JUN",
                                      "JUL",
                                      "AUG",
                                    ];
                                    if (value.toInt() < 0 ||
                                        value.toInt() >= months.length) {
                                      return const Text("");
                                    }
                                    return Text(months[value.toInt()]);
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 10),
                                  FlSpot(1, 20),
                                  FlSpot(2, 45),
                                  FlSpot(3, 30),
                                  FlSpot(4, 55),
                                  FlSpot(5, 65),
                                  FlSpot(6, 85),
                                  FlSpot(7, 75),
                                ],
                                isCurved: true,
                                color: Colors.green,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
