import 'package:expe_traking/main/parent/controller/expense_bloc.dart';
import 'package:expe_traking/main/parent/model/expenses_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../utils/AppValues.dart';
import '../../../../utils/app_utils.dart';

class CategoryWiseExpenseView extends StatelessWidget {
  final Map<ExpenseCategoryEnum, double> expensesCategoryAmountMap;

  final List<Color> pieColors = [
    Colors.blue, // Classic Blue
    Colors.red, // Classic Red
    Colors.green, // Classic Green
    Colors.orange, // Classic Orange
    Colors.purple, // Classic Purple
    Colors.teal, // Classic Teal
    Colors.brown, // Classic Brown
  ];

  CategoryWiseExpenseView({super.key, required this.expensesCategoryAmountMap});

  @override
  Widget build(BuildContext context) {
    double totalExpense = expensesCategoryAmountMap.isEmpty
        ? 0
        : expensesCategoryAmountMap.values.reduce((a, b) => a + b);
    double maxExpense = expensesCategoryAmountMap.isEmpty
        ? 0
        : expensesCategoryAmountMap.values
            .reduce((a, b) => a > b ? a : b); // Get max expense

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
                        itemCount: expensesCategoryAmountMap.length,
                        itemBuilder: (context, index) {
                          var category =
                              expensesCategoryAmountMap.keys.elementAt(index);
                          double expense = expensesCategoryAmountMap[category]!;
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
                              sections: expensesCategoryAmountMap.entries
                                  .map((entry) {
                                int index = expensesCategoryAmountMap.keys
                                    .toList()
                                    .indexOf(entry.key);
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
