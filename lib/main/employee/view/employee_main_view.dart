import 'package:expe_traking/main/employee/controller/bloc_employee.dart';
import 'package:expe_traking/main/employee/controller/employee_helper.dart';
import 'package:expe_traking/main/parent/view/expenses_list_screen.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/app_utils.dart';
import '../../../utils/permission_utils.dart';

class EmployeeMainView extends StatefulWidget {
  static const String route = "employee_screen";

  const EmployeeMainView({super.key});

  @override
  State<StatefulWidget> createState() => _EmployeeMainView();
}

class _EmployeeMainView extends State<EmployeeMainView> {
  late EmployeeHelper employeeHelper;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    employeeHelper = EmployeeHelper();
    employeeHelper.blocEmployee.employeeHelper = employeeHelper;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocEmployee>(
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
          SafeArea(
            child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      employeeHelper.openAddBottomSheet(blocContext: context);

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
      ),
    );
  }
}
