import 'package:expe_traking/main/parent/model/expenses_model.dart';
import 'package:expe_traking/main/parent/view/widget/expenses_detail_view.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/app_utils.dart';
import 'expense_bloc.dart';
import 'expense_events.dart';

enum ExpenseEnum {
  travel,
  meals,
  office,
  software,
  training,
  business,
  miscellaneous
}

class ExpensesHelper {
  List<ExpensesModel> expensesList = [];
  late ExpensesModel selectedDetailModel;
  late BuildContext blocContext;
  int indexUpdated = 0;
  bool newAdded = false;

  ExpensesHelper();

  Future<List<ExpensesModel>> getExpenses() async {
    if (BaseDataController().currentUserRole == UserRole.admin) {
      return await BaseDataController()
          .getExpensesByStatus(ExpensesStatusEnum.approved.name);
    } else {
      return await BaseDataController().getAllExpenses();
    }
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
