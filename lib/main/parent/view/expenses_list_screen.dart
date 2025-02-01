import 'package:expe_traking/main/parent/controller/expenses_helper.dart';
import 'package:expe_traking/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../net/firebase_utils.dart';
import '../model/expenses_model.dart';

class ExpensesListScreen extends StatefulWidget {
  @override
  _ExpensesListScreenState createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  late ExpensesHelper expensesHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    expensesHelper = ExpensesHelper();
  }

  @override
  Widget build(BuildContext context) {
    String userId = "user123"; // Replace with actual user ID

    return Scaffold(
      body: FutureBuilder<List<ExpensesModel>>(
        future: expensesHelper.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}")); // Handle errors
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text("No expenses found")); // Handle empty list
          }

          List<ExpensesModel> expenses = snapshot.data!;

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              ExpensesModel expense = expenses[index];
              print("myExpID " + expense.expId.toString());
              return Card(
                margin: EdgeInsets.all(8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: SizedBox(
                      width: 70, child: Image.network(expense.receiptUrl)),
                  title: Text(expense.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Amount: \$${expense.amount}"),
                  trailing: SizedBox(
                    width: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 10,
                          width: 20,
                          decoration: BoxDecoration(
                              color: ExpensesStatusEnum.pending ==
                                      expense.expensesStatus
                                  ? Colors.grey
                                  : ExpensesStatusEnum.approved ==
                                          expense.expensesStatus
                                      ? Colors.green
                                      : Colors.red,
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(AppUtils.capitalizeFirstLetter(
                              expense.expensesStatus.name)),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    expensesHelper.showExpenseDetailsDialog(context, expense);
                    // Open details or perform an action
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
