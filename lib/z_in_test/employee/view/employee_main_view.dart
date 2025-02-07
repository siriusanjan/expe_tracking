import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data_domain/form_employee_expense/bloc_employee_form.dart';
import '../../../data_domain/form_employee_expense/employee_form_helper.dart';
import '../../../ui_layer/main_expenses/view/expenses_list_screen.dart';

class EmployeeMainView extends StatefulWidget {
  static const String route = "employee_screen";

  const EmployeeMainView({super.key});

  @override
  State<StatefulWidget> createState() => _EmployeeMainView();
}

class _EmployeeMainView extends State<EmployeeMainView> {
  late EmployeeFormHelper employeeHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    employeeHelper = EmployeeFormHelper();
    employeeHelper.blocEmployee.employeeHelper = employeeHelper;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocEmployeeForm>(
      create: (BuildContext blocContext) => employeeHelper.blocEmployee,
      child: Stack(
        children: [
          Container(
            color: Colors.red,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: ExpensesListScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
