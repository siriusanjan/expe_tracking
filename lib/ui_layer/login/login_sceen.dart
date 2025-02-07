import 'package:expe_traking/data_domain/firebase/firebase_utils.dart';
import 'package:expe_traking/data_domain/login/login_helper.dart';
import 'package:flutter/material.dart';

import '../AppStyles.dart';
import '../../data_domain/utils/AppValues.dart';
import '../app_widget.dart';
import '../main_expenses/parent_view.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "login_screen";

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginHelper loginHelper;
  bool showManual = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginHelper = LoginHelper(setLoginState);
    loginHelper.autoLogin(context).then((autologin) {
      print("curretnAutoLoginStatus$autologin");
      if (!autologin) {
        showManual = true;
        setState(() {});
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          ParentView.route, // Named route for LoginScreen
          (route) =>
              route.settings.name ==
              ParentView.route, // Removes all previous routes
        );
      }
    });
  }

  void setLoginState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return !showManual
        ? const CircularProgressIndicator()
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: const Text("Login")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      width: 300,
                      height: 50,
                      child: SwitchListTile(
                        title: const Text("Sign Admin"),
                        activeTrackColor: AppValues.primaryColor,
                        activeColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade200,
                        value: loginHelper.doSignUp,
                        onChanged: loginHelper.toggleAdmin,
                      ),
                    ),
                  ),
                  if (loginHelper
                      .doSignUp) // Show role selection when admin sign-up is enabled
                    Container(
                      height: 150,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // This makes it scroll horizontally
                        child: SizedBox(
                            child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: AppValues.mainScreenWidth * 0.45,
                                  child: RadioListTile<UserRole>(
                                    title: const Text("Admin"),
                                    value: UserRole.admin,
                                    groupValue: loginHelper.adminRole,
                                    onChanged: (value) {
                                      if (value != null) {
                                        loginHelper.adminRole = value;
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                    width: AppValues.mainScreenWidth * 0.45,
                                    child: RadioListTile<UserRole>(
                                      title: const Text("Manager"),
                                      value: UserRole.manager,
                                      groupValue: loginHelper.adminRole,
                                      onChanged: (value) {
                                        if (value != null) {
                                          loginHelper.adminRole = value;
                                          setState(() {});
                                        }
                                      },
                                    )),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                    width: AppValues.mainScreenWidth * 0.45,
                                    child: RadioListTile<UserRole>(
                                      title: const Text("Employee"),
                                      value: UserRole.employee,
                                      groupValue: loginHelper.adminRole,
                                      onChanged: (value) {
                                        if (value != null) {
                                          loginHelper.adminRole = value;
                                          setState(() {});
                                        }
                                      },
                                    )),
                                Container(
                                    width: AppValues.mainScreenWidth * 0.45,
                                    child: RadioListTile<UserRole>(
                                      title: const Text(
                                        "None",
                                      ),
                                      value: UserRole.none,
                                      groupValue: loginHelper.adminRole,
                                      onChanged: (value) {
                                        if (value != null) {
                                          loginHelper.adminRole = value;
                                          setState(() {});
                                        }
                                      },
                                    )),
                              ],
                            )
                          ],
                        )),
                      ),
                    ),
                  Expanded(
                    child: Form(
                      key: loginHelper.formKey,
                      child: Column(
                        mainAxisAlignment: loginHelper
                            .doSignUp?MainAxisAlignment.start:MainAxisAlignment.center,
                        children: [
                          TextFieldWidget(
                            hintText: "Enter Email",
                            icon: Icons.mail,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            textEditingController: loginHelper.emailController,
                            validatorErrorString: "Please enter your email",
                          ),
                          const SizedBox(height: 16),
                          TextFieldWidget(
                            hintText: "Enter password",
                            icon: Icons.password,
                            obscure: true,
                            keyboardType: TextInputType.visiblePassword,
                            textEditingController:
                                loginHelper.passwordController,
                            validatorErrorString:
                                "Please enter your password length greater than 6",
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              loginHelper.processSign(context: context);
                            },
                            style: AppStyles.elevatedButtonStyle(),
                            child: Text(
                              loginHelper.doSignUp
                                  ? "Sign up as ${loginHelper.adminRole}"
                                  : "Login",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    loginHelper.onDispose();
  }
}
