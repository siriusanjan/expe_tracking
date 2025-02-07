import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ui_layer/main_expenses/view/widget/expenses_detail_view.dart';
import '../../ui_layer/main_expenses/view/widget/filter_view.dart';
import '../firebase/firebase_utils.dart';
import '../storage/database_helper.dart';
import '../../ui_layer/employee_form/expense_form.dart';
import '../utils/AppValues.dart';
import '../utils/base_data_controller.dart';
import 'expense_bloc.dart';
import 'expense_events.dart';
import 'model/expenses_model.dart';

class ExpensesHelper {
  late ExpenseListBloc expenseListBloc;
  List<ExpensesModel> expensesList = [];
  int recordeExpenseLength = 0;
  late ExpensesModel selectedDetailModel;
  late BuildContext blocContext;
  int indexUpdated = 0;
  bool newAdded = false;
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  double currentOffset = 0;
  File? finalPickedFile;

  ExpensesHelper() {
    expenseListBloc = ExpenseListBloc(expensesHelper: this);
  }

  Future<List<ExpensesModel>> getExpenses() async {
    if (BaseDataController().currentUserRole == UserRole.admin) {
      return await BaseDataController()
          .getExpensesByStatus(ExpensesStatusEnum.approved.name);
    } else {
      return await BaseDataController().getAllExpenses();
    }
  }

  void loadMoreExpense() {
    recordeExpenseLength = expenseListBloc.state.expenseList.length;
    print("previousLength $recordeExpenseLength");
    expenseListBloc.add(LoadMoreExpensesEvent());

    print("currentLength ${expenseListBloc.state.expenseList.length}");
  }

  int addUpdateExpenses() {
    expensesList = List.from(expenseListBloc.state.expenseList);

    if (indexUpdated > -1) {
      // Animate new items added to the list
      int updatedIndex = indexUpdated;
      indexUpdated = -1;
      if (newAdded) {
        listKey.currentState?.insertItem(updatedIndex);
        return -1;
      } else {
        return 0;
      }
    }
    final currentLength = expenseListBloc.state.expenseList.length;
    if (currentLength != recordeExpenseLength) {
      // Re-insert the updated item
      listKey.currentState?.insertAllItems(
          recordeExpenseLength - 1, ((currentLength) - recordeExpenseLength));
    } else if (!expenseListBloc.state.hasMoreData) {
      // listKey.currentState?.removeItem(expensesList.length,
      //     (context, animation) => const CircularProgressIndicator());
    }

    return -1;
  }

  bool canListViewRebuilds(
      {required ExpenseListState previous, required ExpenseListState current}) {
    return current.expenseList.isEmpty ||
        current.currentPage == 1 ||
        previous.expenseList != current.expenseList ||
        (previous.hasMoreData && !current.hasMoreData);
  }

  Future<Map<ExpenseCategoryEnum, double>> getExpenseCategoryWiseTotal({
    DateTime? startDate,
    DateTime? endDate,
    ExpensesStatusEnum? expensesStatusFilter,
    ExpenseCategoryEnum? expenseCategoryEnum,
    String? employeeEmailFilter,
  }) async {
    return await DatabaseHelper.instance.getCategoryWiseTotalExpenses(
      startDate: startDate,
      endDate: endDate,
      expensesStatusFilter: expensesStatusFilter,
      expenseCategoryEnum: expenseCategoryEnum,
      employeeEmailFilter: employeeEmailFilter,
    );
  }

  Future<List<ExpensesModel>> filterExpenses({
    required Map<dynamic, dynamic> filterGear,
    required List<ExpensesModel> expensesList,
  }) async {
    final List<ExpensesModel> expenses = expensesList;
    await BaseDataController().getFilterList(employeeID: "");

    final expenseList = DatabaseHelper.instance
        .getFilteredExpenses(filterGear: filterGear, page: 0);
    // final resultExpenses = expenses.where((expense) {
    //   // Date Filter
    //   bool dateFilter = true;
    //   if (startDate != null && endDate != null) {
    //     dateFilter = expense.timeStamp != null &&
    //         expense.timeStamp!.isAfter(startDate) &&
    //         expense.timeStamp!.isBefore(endDate);
    //   }
    //
    //   // Expenses Status Filter
    //   bool statusFilter = true;
    //   if (expensesStatusFilter != null) {
    //     statusFilter = expense.expensesStatus == expensesStatusFilter;
    //   }
    //
    //   // Employee Email Filter
    //   bool emailFilter = true;
    //   if (employeeEmailFilter != null) {
    //     emailFilter = expense.authorMail == employeeEmailFilter;
    //   }
    //   // Employee Email Filter
    //   bool expenseCategoryEnumFilter = true;
    //   if (expenseCategoryEnum != null) {
    //     expenseCategoryEnumFilter =
    //         expense.category == expenseCategoryEnum.name;
    //   }
    //
    //   // Combine all filters
    //   final filterResult = dateFilter &&
    //       statusFilter &&
    //       emailFilter &&
    //       expenseCategoryEnumFilter;
    //   return filterResult;
    // }).toList();
    listKey = GlobalKey<AnimatedListState>();

    return expenseList;
  }

  Map<ExpenseCategoryEnum, double> getCategoryWiseTotal(
      List<ExpensesModel> expenses) {
    Map<ExpenseCategoryEnum, double> categoryTotals = {};

    for (var expense in expenses) {
      String category = expense.category.name;
      ExpenseCategoryEnum categoryEnum = ExpenseCategoryEnum.values.firstWhere(
        (e) => e.name.toLowerCase() == category.toLowerCase(),
      );
      double amount = expense.amount;

      if (categoryTotals.containsKey(categoryEnum)) {
        categoryTotals[categoryEnum] = categoryTotals[categoryEnum]! + amount;
      } else {
        categoryTotals[categoryEnum] = amount;
      }
    }

    return categoryTotals;
  }

  void openAddBottomSheet({required BuildContext blocContext}) {
    BaseDataController().filterMap = {};
    expenseListBloc.add(FilterExpensesEvent(filterGear: {}));
    showDialog(
      context: blocContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BlocProvider<ExpenseListBloc>.value(
            value: expenseListBloc,
            child: Dialog(
              insetPadding: EdgeInsets.all(Platform.isAndroid?10:30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Platform.isAndroid?8.0:16),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context)
                            .viewInsets
                            .bottom, // Adjust for keyboard
                      ),
                      child: ExpenseForm());
                },
              ),
            ));
      },
    );
  }

  void showFilterDialog(BuildContext blocContext) {
    showModalBottomSheet(
      useSafeArea: true,
      context: blocContext,
      isDismissible: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BlocProvider<ExpenseListBloc>.value(
            value: expenseListBloc,
            child: const Wrap(
              children: [
                FilterView(),
              ],
            ));
      },
    );
  }

  void showExpenseDetailsDialog(BuildContext context, ExpensesModel expense) {
    selectedDetailModel = expense;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ExpenseDetailView(expensesHelper: this, expense: expense);
      },
    );
  }

  void updateExpanse() {
    // BaseDataController().updateExpenseStatus(selectedDetailModel., status)
  }

  void onUpdate(ExpensesModel model, {bool shouldUpdate = false}) {
    BlocProvider.of<ExpenseListBloc>(blocContext).add(UpdateExpenseEvent(
        expense: model,
        shouldUpdate: shouldUpdate,
        updatedIndex: (updatedIndex, isNew) {
          indexUpdated = updatedIndex;
          newAdded = isNew;
        }));
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  void disposeCallers() {}
}
