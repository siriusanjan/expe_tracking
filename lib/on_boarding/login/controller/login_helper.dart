import 'package:expe_traking/main/admin/view/admin_main_view.dart';
import 'package:expe_traking/main/employee/view/employee_main_view.dart';
import 'package:expe_traking/main/manager/view/manager_main_view.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:expe_traking/utils/AppDialogue.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginHelper {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool adminSignUp = false;
  Function setLoginState;

  LoginHelper(this.setLoginState);

  void toggleAdmin(bool value) {
    adminSignUp = !adminSignUp;
    setLoginState();
  }

  Future<void> processSign({required BuildContext context}) async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    if (formKey.currentState!.validate()) {
      AppDialogue.showLoadingDialog(context);
      if (adminSignUp) {
        await BaseDataController()
            .createUserWithRole(
                email: emailController.text.trim(),
                password: passwordController.text,
                userRole: UserRole.admin,
                catchErrorMessage: (message) {
                  Navigator.pop(context);
                  print("fajfjafnuot");
                  AppDialogue.noUserFoundSnackBar(
                      context: context, message: message + " Unsuccessful! ");
                  if (FocusScope.of(context).hasFocus) {
                    FocusScope.of(context).unfocus();
                  }
                })
            .then((_) {
          Navigator.pop(context);
          AppDialogue.noUserFoundSnackBar(
              context: context,
              message: "Admin created\n Proceed SignIn",
              color: Colors.green.shade900);
          adminSignUp = false;
        });
      } else {
        login(context: context);
      }
    }
  }

  void login({required BuildContext context}) {
    BaseDataController()
        .loginIn(
            email: emailController.text.trim(),
            password: passwordController.text,
            catchErrorMessage: (message) {
              Navigator.pop(context);

              AppDialogue.noUserFoundSnackBar(
                  context: context, message: "No user found! " + message);
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
              }
            })
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
          AppDialogue.noUserFoundSnackBar(context: context, message: "");
          break;
      }
    });
  }
}
