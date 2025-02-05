import 'package:expe_traking/main/parent/model/expenses_model.dart';
import 'package:expe_traking/main/parent/view/widget/expenses_detail_view.dart';
import 'package:expe_traking/main/parent/view/widget/filter_view.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/app_utils.dart';
import 'expense_bloc.dart';
import 'expense_events.dart';

class ExpensesHelper {
  late ExpenseListBloc expenseListBloc;
  List<ExpensesModel> expensesList = [];
  late ExpensesModel selectedDetailModel;
  late BuildContext blocContext;
  int indexUpdated = 0;
  bool newAdded = false;

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

  Future<List<ExpensesModel>> filterExpenses({
    required List<ExpensesModel> expensesList,
    DateTime? startDate,
    DateTime? endDate,
    ExpensesStatusEnum? expensesStatusFilter,
    ExpenseCategoryEnum? expenseCategoryEnum,
    String? employeeEmailFilter,
  }) async {
    final List<ExpensesModel> expenses = expensesList;
    await BaseDataController().getFilterList(employeeID: "");
    final resultExpenses = expenses.where((expense) {
      // Date Filter
      bool dateFilter = true;
      if (startDate != null && endDate != null) {
        dateFilter = expense.timeStamp != null &&
            expense.timeStamp!.isAfter(startDate) &&
            expense.timeStamp!.isBefore(endDate);
      }

      // Expenses Status Filter
      bool statusFilter = true;
      if (expensesStatusFilter != null) {
        statusFilter = expense.expensesStatus == expensesStatusFilter;
      }

      // Employee Email Filter
      bool emailFilter = true;
      if (employeeEmailFilter != null) {
        emailFilter = expense.authorMail == employeeEmailFilter;
      }
      // Employee Email Filter
      bool expenseCategoryEnumFilter = true;
      if (expenseCategoryEnum != null) {
        expenseCategoryEnumFilter =
            expense.category == expenseCategoryEnum.name;
      }

      // Combine all filters
      final filterResult = dateFilter &&
          statusFilter &&
          emailFilter &&
          expenseCategoryEnumFilter;
      return filterResult;
    }).toList();
    return resultExpenses;
  }

  Map<ExpenseCategoryEnum, double> getCategoryWiseTotal(
      List<ExpensesModel> expenses) {
    Map<ExpenseCategoryEnum, double> categoryTotals = {};

    for (var expense in expenses) {
      String category = expense.category;
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

  void showFilterDialog(BuildContext blocContext) {
    showModalBottomSheet(
      useSafeArea: true,
      context: blocContext,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BlocProvider<ExpenseListBloc>.value(
            value: expenseListBloc,
            child: Wrap(
              children: [
                const FilterView(),
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
