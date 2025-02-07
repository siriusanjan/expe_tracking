import 'package:expe_traking/data_domain/firebase/firebase_utils.dart';
import 'package:expe_traking/ui_layer/main_expenses/view/widget/cat_wise_expense_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data_domain/main_expenses/expense_bloc.dart';
import '../../../data_domain/main_expenses/expense_events.dart';
import '../../../data_domain/main_expenses/expenses_helper.dart';
import '../../../data_domain/main_expenses/model/expenses_model.dart';
import '../../../data_domain/utils/AppValues.dart';
import '../../../data_domain/utils/app_utils.dart';
import '../../../data_domain/utils/base_data_controller.dart';

class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

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
              BlocBuilder<ExpenseListBloc, ExpenseListState>(
                  buildWhen: (previous, current) {
                return current.currentPage == 1;
              }, builder: (context, state) {
                return state.expenseCategoryTotal.isEmpty?Container(): CategoryWiseExpenseView(
                    expensesCategoryAmountMap: state.expenseCategoryTotal);
              }),
              BlocConsumer<ExpenseListBloc, ExpenseListState>(
                listener: (context, state) {
                  final i = expensesHelper.addUpdateExpenses();
                  if (!i.isNegative) {
                    expensesHelper.listKey.currentState?.removeItem(
                      i,
                      (context, animation) => _buildExpenseCard(
                          expensesHelper.expensesList[i], context),
                    );
                    Future.delayed(const Duration(milliseconds: 300), () {
                      // Re-insert the updated item
                      expensesHelper.listKey.currentState?.insertItem(i);
                    });
                  }
                },
                buildWhen: (previous, current) => expensesHelper
                    .canListViewRebuilds(previous: previous, current: current),
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
                  expensesHelper.expensesList = List.from(state.expenseList);
                  return Expanded(
                    child: AnimatedList(
                      key: expensesHelper.listKey,
                      initialItemCount: state.expenseList.length +
                          (state.hasMoreData ? 1 : 0),
                      itemBuilder: (context, index, animation) {
                        if (index == state.expenseList.length) {
                          if (state.hasMoreData) {
                            expensesHelper.loadMoreExpense();
                          }
                          return Center(child: Container());
                        }
                        final expenses = state.expenseList;
                        return expenses.length > index
                            ? SlideTransition(
                                position: animation.drive(
                                  expensesHelper.newAdded
                                      ? Tween<Offset>(
                                          begin: const Offset(
                                              0, -1), // Start off-screen
                                          end: Offset.zero,
                                        ).chain(
                                          CurveTween(curve: Curves.easeInOut))
                                      : Tween<Offset>(
                                          begin: const Offset(
                                              0, 1), // Start off-screen
                                          end: Offset.zero,
                                        ).chain(
                                          CurveTween(curve: Curves.easeInOut)),
                                ),
                                child:
                                    _buildExpenseCard(expenses[index], context),
                              )
                            : Container();
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
                            backgroundColor: AppValues.primaryColor,
                            child: const Icon(
                              Icons.search,
                              color: AppValues.backgroundColor,
                            ),
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
                            backgroundColor: AppValues.primaryColor,
                            child: const Icon(
                              Icons.tune,
                              color: AppValues.backgroundColor,
                            ),
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
                                expensesHelper.openAddBottomSheet(
                                    blocContext: context);
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
          style: const TextStyle(fontWeight: FontWeight.bold),
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
