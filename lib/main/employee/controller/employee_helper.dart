import 'package:expe_traking/main/employee/controller/bloc_employee.dart';
import 'package:expe_traking/main/employee/view/widget/expense_form.dart';
import 'package:flutter/material.dart';

import '../../../utils/AppValues.dart';

class EmployeeHelper {
  BlocEmployee blocEmployee = BlocEmployee(EmployeeState.initialState);

  EmployeeHelper();

  void openAddBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
        useSafeArea: true,
        context: context,


        isScrollControlled: true,
        builder: (context) {
          return Container(
              decoration: BoxDecoration(
                  color: AppValues.backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              padding: const EdgeInsets.all(16), child: ExpenseForm());
        });
  }
}
