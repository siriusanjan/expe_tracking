import 'package:expe_traking/ui_layer/main_expenses/parent_view.dart';
import 'package:expe_traking/data_domain/firebase/firebase_utils.dart';
import 'package:flutter/material.dart';

import '../storage/auth_helper.dart';
import '../utils/AppDialogue.dart';
import '../utils/base_data_controller.dart';

class LoginHelper {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool doSignUp = false;
  Function setLoginState;
  String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  UserRole adminRole = UserRole.none;

  LoginHelper(this.setLoginState);

  void toggleAdmin(bool value) {
    doSignUp = !doSignUp;
    setLoginState();
  }

  Future<bool> autoLogin(BuildContext context) async {
    return BaseDataController().autoLogin(context);
  }

  Future<void> processSign({required BuildContext context}) async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }
    if (formKey.currentState!.validate()) {
      AppDialogue.showLoadingDialog(context);
      if (doSignUp) {
        await BaseDataController()
            .createUserWithRole(
                email: emailController.text.trim(),
                password: passwordController.text,
                userRole: adminRole,
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
              message: "${adminRole.name} created\n Proceed SignIn",
              color: Colors.green.shade900);
          doSignUp = false;
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
    final email = emailController.text.trim().isEmpty
        ? "em@em.com"
        : emailController.text.trim();
    final password =
        passwordController.text.isEmpty ? "em1234" : passwordController.text;
    BaseDataController()
        .loginIn(
            email: email,
            password: password,
            catchErrorMessage: (message) {
              Navigator.pop(context);

              AppDialogue.noUserFoundSnackBar(
                  context: context, message: "No user found! " + message);
              if (FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
              }
            })
        .then((_) async {
      await AuthHelper.signInWithEmail(
          email, password, BaseDataController().currentUserRole);
      Navigator.pushNamedAndRemoveUntil(
        context,
        ParentView.route, // Named route for LoginScreen
        (route) =>
            route.settings.name ==
            ParentView.route, // Removes all previous routes
      );
    });
  }

  void onDispose() {}
}
