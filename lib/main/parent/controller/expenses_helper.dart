import 'package:expe_traking/main/parent/model/expenses_model.dart';
import 'package:expe_traking/main/parent/view/widget/expenses_detail_view.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_utils.dart';

class ExpensesHelper {
  List<ExpensesModel> expensesList = [];
  late ExpensesModel selectedDetailModel;

  ExpensesHelper();

  Future<List<ExpensesModel>> getExpenses() async {
    if (BaseDataController().currentUserRole == UserRole.admin) {
      return await BaseDataController()
          .getExpensesByStatus(UserRole.admin.name);
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
