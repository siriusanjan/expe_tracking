import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../utils/AppValues.dart';
import '../../../../utils/app_utils.dart';

enum ExpenseEnum {
  travel,
  meals,
  office,
  software,
  training,
  business,
  miscellaneous
}

class CategoryWiseExpenseView extends StatelessWidget {
  final Map<ExpenseEnum, double> expenses = {
    ExpenseEnum.travel: 250.75,
    ExpenseEnum.meals: 120.50,
    ExpenseEnum.office: 340.00,
    ExpenseEnum.software: 150.25,
    ExpenseEnum.training: 200.00,
    ExpenseEnum.business: 180.80,
    ExpenseEnum.miscellaneous: 90.40,
  };

  final List<Color> pieColors = [
    Colors.blue,          // Classic Blue
    Colors.red,           // Classic Red
    Colors.green,         // Classic Green
    Colors.orange,        // Classic Orange
    Colors.purple,        // Classic Purple
    Colors.teal,          // Classic Teal
    Colors.brown,         // Classic Brown
  ];
  @override
  Widget build(BuildContext context) {
    double totalExpense = expenses.values.reduce((a, b) => a + b);
    double maxExpense =
        expenses.values.reduce((a, b) => a > b ? a : b); // Get max expense

    return Container(
      height: 150,
      child: Card(
        shadowColor: AppValues.backgroundColor,
        surfaceTintColor: AppValues.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Expense List Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          var category = expenses.keys.elementAt(index);
                          double expense = expenses[category]!;
                          double progress = expense /
                              maxExpense; // Normalize for progress bar

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      category.name.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      "\$${AppUtils.formatDollor(expense)}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[300],
                                  color: pieColors[index],
                                  minHeight: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 20,
              ),
              // Pie Chart Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: expenses.entries.map((entry) {
                                int index =
                                    expenses.keys.toList().indexOf(entry.key);
                                return PieChartSectionData(
                                  value: entry.value,
                                  color: pieColors[index],
                                  radius: 25,
                                  title: '',
                                );
                              }).toList(),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "\$${AppUtils.formatDollor(totalExpense)}",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
