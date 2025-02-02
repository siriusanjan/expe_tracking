import 'package:expe_traking/main/admin/view/admin_main_view.dart';
import 'package:expe_traking/main/employee/view/employee_main_view.dart';
import 'package:expe_traking/main/manager/view/manager_main_view.dart';
import 'package:expe_traking/main/parent/parent_view.dart';
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
  String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
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
    } else {
      AppDialogue.showLoadingDialog(context);

      login(context: context);
    }
  }

  void login({required BuildContext context}) {
    BaseDataController()
        .loginIn(
            email: emailController.text.trim().isEmpty
                ? "man@man.com"
                : emailController.text.trim(),
            password: passwordController.text.isEmpty
                ? "man1234"
                : passwordController.text,
            catchErrorMessage: (message) {
              Navigator.pop(context);

              AppDialogue.noUserFoundSnackBar(
                  context: context, message: "No user found! " + message);
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
              }
            })
        .then((_) {
      Navigator.pushReplacementNamed(context, ParentView.route);
    });
  }
  void onDispose(){

  }
}
