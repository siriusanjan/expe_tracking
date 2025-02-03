import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/app_utils.dart';
import '../controller/expense_bloc.dart';
import '../controller/expense_events.dart';
import '../controller/expenses_helper.dart';
import '../model/expenses_model.dart';

class ExpensesListScreen extends StatefulWidget {
  @override
  _ExpensesListScreenState createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  late ExpensesHelper expensesHelper;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<ExpensesModel> _expenses = [];

  @override
  void initState() {
    super.initState();
    expensesHelper = ExpensesHelper();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseListBloc(expensesHelper: expensesHelper)
        ..add(FetchExpensesEvent()),
      child: Container(
        color: AppValues.backgroundColor,
        child: BlocConsumer<ExpenseListBloc, ExpenseListState>(
          listener: (context, state) {
            if (expensesHelper.indexUpdated > -1) {
              // Animate new items added to the list
              int updatedIndex = expensesHelper.indexUpdated;
              expensesHelper.indexUpdated = -1;
              _expenses = List.from(state.expenseList);
              if (expensesHelper.newAdded) {
                print("newwAddedItem ");
                _listKey.currentState?.insertItem(updatedIndex);
              } else {
                print("updatedIndex "+updatedIndex.toString());
                // Animate item update
                _listKey.currentState?.removeItem(
                  updatedIndex,
                  (context, animation) =>
                      _buildExpenseCard(_expenses[updatedIndex], context),
                );
                Future.delayed(Duration(milliseconds: 300), () {
                  // Re-insert the updated item
                  _listKey.currentState?.insertItem(updatedIndex);
                });
              }
            }
          },
          builder: (context, state) {
            expensesHelper.blocContext = context;
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.error != null) {
              return Center(child: Text("Error: ${state.error}"));
            } else if (state.expenseList.isEmpty) {
              BaseDataController().updateExpenseList = expensesHelper.onUpdate;

              return const Center(child: Text("No expenses found"));
            }

            _expenses = List.from(state.expenseList);
            return AnimatedList(
              key: _listKey,
              initialItemCount: _expenses.length,
              itemBuilder: (context, index, animation) {
                ExpensesModel expense = _expenses[index];

                return SlideTransition(
                  position: animation.drive(
                    expensesHelper.newAdded
                        ? Tween<Offset>(
                            begin: const Offset(0, -1), // Start off-screen
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut))
                        : Tween<Offset>(
                            begin: const Offset(0, 1), // Start off-screen
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeInOut)),
                  ),
                  child: _buildExpenseCard(expense, context),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpenseCard(ExpensesModel expense, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: SizedBox(
          width: 70,
          child: Image.network(expense.receiptUrl),
        ),
        title: Text(
          expense.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  color: expense.expensesStatus == ExpensesStatusEnum.pending
                      ? Colors.grey
                      : expense.expensesStatus == ExpensesStatusEnum.approved
                          ? Colors.green
                          : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  AppUtils.capitalizeFirstLetter(expense.expensesStatus.name),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          expensesHelper.showExpenseDetailsDialog(context, expense);
          BaseDataController().updateExpenseList = expensesHelper.onUpdate;
        },
      ),
    );
  }
}
