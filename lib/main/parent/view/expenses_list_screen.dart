import 'package:expe_traking/main/parent/view/widget/cat_wise_expense_view.dart';
import 'package:expe_traking/net/firebase_utils.dart';
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

  @override
  void initState() {
    super.initState();
    expensesHelper = ExpensesHelper();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    expensesHelper.disposeCallers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          expensesHelper.expenseListBloc..add(FetchExpensesEvent()),
      child: Container(
        color: AppValues.backgroundColor,
        child: Stack(children: [
          Column(
            children: [
              CategoryWiseExpenseView(),
              BlocConsumer<ExpenseListBloc, ExpenseListState>(
                listener: (context, state) {
                  final i = expensesHelper.addUpdateExpenses();
                  if (!i.isNegative) {
                    expensesHelper.listKey.currentState?.removeItem(
                      expensesHelper.addUpdateExpenses(),
                      (context, animation) => _buildExpenseCard(
                          expensesHelper.expensesList[i], context),
                    );
                    Future.delayed(Duration(milliseconds: 300), () {
                      // Re-insert the updated item
                      expensesHelper.listKey.currentState?.insertItem(i);
                    });
                  }
                },
                builder: (context, state) {
                  expensesHelper.blocContext = context;
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.error != null) {
                    return Center(child: Text("Error: ${state.error}"));
                  } else if (state.expenseList.isEmpty) {
                    BaseDataController().updateExpenseList =
                        expensesHelper.onUpdate;
                    return const Center(child: Text("No expenses found"));
                  }
                  print(
                      "stateCallInHere" + state.expenseList.length.toString());
                  expensesHelper.expensesList = List.from(state.expenseList);

                  return Expanded(
                    child: AnimatedList(
                      // controller: expensesHelper.scrollController,
                      key: expensesHelper.listKey,
                      initialItemCount: expensesHelper.expensesList.length +
                          (state.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index, animation) {
                        if (index == state.expenseList.length) {
                          expensesHelper.loadMoreExpense();
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final expense = state.expenseList[index];
                        return SlideTransition(
                          position: animation.drive(
                            expensesHelper.newAdded
                                ? Tween<Offset>(
                                    begin:
                                        const Offset(0, -1), // Start off-screen
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: Curves.easeInOut))
                                : Tween<Offset>(
                                    begin:
                                        const Offset(0, 1), // Start off-screen
                                    end: Offset.zero,
                                  ).chain(CurveTween(curve: Curves.easeInOut)),
                          ),
                          child: _buildExpenseCard(expense, context),
                        );
                      },
                    ),
                  );
                },
              )
            ],
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SafeArea(
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 15.0, bottom: 10),
                          child: FloatingActionButton(
                            onPressed: () {
                              expensesHelper.showFilterDialog(context);
                            },
                            child: const Icon(
                              Icons.search,
                              color: AppValues.backgroundColor,
                            ),
                            backgroundColor: AppValues.primaryColor,
                          ),
                        )),
                  ),
                  SafeArea(
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 15.0, bottom: 15),
                          child: FloatingActionButton(
                            onPressed: () {
                              expensesHelper.showFilterDialog(context);
                            },
                            child: const Icon(
                              Icons.tune,
                              color: AppValues.backgroundColor,
                            ),
                            backgroundColor: AppValues.primaryColor,
                          ),
                        )),
                  ),
                  if (BaseDataController().currentUserRole == UserRole.employee)
                    SafeArea(
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 15.0, bottom: 15),
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                // employeeHelper.openAddBottomSheet(blocContext: context);
                              },
                              icon: const Icon(
                                Icons.add,
                                color: AppValues.backgroundColor,
                              ),
                              label: const Text(
                                "Add Expenses",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppValues.primaryColor,
                            ),
                          )),
                    ),
                ],
              )),
        ]),
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
        subtitle: Text("Amount: \$${AppUtils.formatDollor(expense.amount)}"),
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
