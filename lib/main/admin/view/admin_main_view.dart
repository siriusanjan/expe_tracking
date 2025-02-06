import 'package:expe_traking/main/admin/controller/bloc_employee.dart';
import 'package:expe_traking/main/admin/controller/employee_helper.dart';
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

class AdminMainView extends StatefulWidget {
  static const String route = "admin_screen";

  const AdminMainView({super.key});

  @override
  State<StatefulWidget> createState() => _AdminMainView();
}

class _AdminMainView extends State<AdminMainView> {
  late AdminHelper adminHelper;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    adminHelper = AdminHelper();
    adminHelper.blocAdmin.adminHelper = adminHelper;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BlocAdmin>(
      create: (BuildContext blocContext) => adminHelper.blocAdmin,
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
