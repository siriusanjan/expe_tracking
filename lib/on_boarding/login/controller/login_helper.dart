import 'package:expe_traking/main/admin/view/admin_main_view.dart';
import 'package:expe_traking/main/employee/view/employee_main_view.dart';
import 'package:expe_traking/main/manager/view/manager_main_view.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:expe_traking/utils/AppDialogue.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';

class LoginHelper {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginHelper();

  void login({required BuildContext context}) {
    if (formKey.currentState!.validate()) {
      AppDialogue.showLoadingDialog(context);
      BaseDataController()
          .loginIn(
              email: emailController.text.trim(),
              password: passwordController.text)
          .then((_) {
        switch (BaseDataController().currentUserRole) {
          case UserRole.admin:
            // TODO: Handle this case.
            Navigator.pushReplacementNamed(context, AdminMainView.route);
            break;

          case UserRole.manager:
            // TODO: Handle this case.
            Navigator.pushReplacementNamed(context, ManagerMainView.route);
            break;

          case UserRole.employee:
            // TODO: Handle this case.
            Navigator.pushReplacementNamed(context, EmployeeMainView.route);
            break;

          case UserRole.none:
            Navigator.pop(context);
            AppDialogue.noUserFoundSnackBar(context: context);
            break;
        }
      });
    }
  }
}
