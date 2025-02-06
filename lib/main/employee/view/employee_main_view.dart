import 'package:expe_traking/main/parent/form_employee_expense/employee_form_helper.dart';
import 'package:expe_traking/main/parent/view/expenses_list_screen.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/app_utils.dart';
import '../../../utils/permission_utils.dart';
import '../../parent/form_employee_expense/bloc_employee_form.dart';

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
            child: Center(
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
