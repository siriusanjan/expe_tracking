import 'package:expe_traking/main/admin/view/admin_main_view.dart';
import 'package:expe_traking/main/parent/form_employee_expense/employee_form_helper.dart';
import 'package:expe_traking/main/employee/view/employee_main_view.dart';
import 'package:expe_traking/main/manager/view/manager_main_view.dart';
import 'package:expe_traking/main/parent/parent_helper.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/app_utils.dart';
import '../../../../utils/permission_utils.dart';

class ParentView extends StatelessWidget {
  static const String route = "parent_screen";
  final ParentHelper parentHelper = ParentHelper();

  ParentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 300,
        leading: Row(
          children: [
            IconButton(
              onPressed: () {
                parentHelper.openAddBottomSheet(context: context);
              },
              icon: const Icon(
                Icons.account_circle,
                color: AppValues.primaryColor,
                size: 40,
              ),
            ),
            const Padding(padding: EdgeInsets.all(4)),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: AppUtils.getGreeting(),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text:
                      "\n${BaseDataController().user?.email!.split('@')[0].toUpperCase()}",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                ),
              ]),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: const [
          Icon(
            Icons.notifications_none_outlined,
            color: AppValues.primaryColor,
            size: 38,
          ),
        ],
      ),
      body: BaseDataController().currentUserRole == UserRole.employee
          ? EmployeeMainView()
          : BaseDataController().currentUserRole == UserRole.admin
              ? AdminMainView()
              : ManagerMainView(),
    );
  }
}
