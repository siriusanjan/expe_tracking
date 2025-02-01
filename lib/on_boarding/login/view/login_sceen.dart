import 'package:expe_traking/on_boarding/login/controller/login_helper.dart';
import 'package:expe_traking/utils/AppStyles.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_widget.dart';

class LoginScreen extends StatefulWidget {
  static const String route = "login_screen";

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginHelper loginHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginHelper = LoginHelper(setLoginState);
  }

  void setLoginState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 200,
                height: 50,
                child: SwitchListTile(
                  title: Text("Sign Admin"),
                  activeTrackColor: AppValues.primaryColor,
                  activeColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade200,
                  value: loginHelper.adminSignUp,
                  onChanged: loginHelper.toggleAdmin,
                ),
              ),
            ),
            Expanded(
              child: Form(
                key: loginHelper.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TextFormField(
                    //   autofocus: false,
                    //   controller: loginHelper.emailController,
                    //   decoration: const InputDecoration(labelText: "Email"),
                    //   keyboardType: TextInputType.emailAddress,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return "Please enter your email";
                    //     }
                    //     return null;
                    //   },
                    // ),
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
                      textEditingController: loginHelper.passwordController,
                      validatorErrorString:
                          "Please enter your password length geater than 6",
                    ),
                    // TextFormField(
                    //   controller: loginHelper.passwordController,
                    //   decoration: const InputDecoration(labelText: "Password"),
                    //   obscureText: true,
                    //   autofocus: false,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return "Please enter your password";
                    //     }
                    //     return null;
                    //   },
                    // ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        loginHelper.processSign(context: context);
                      },
                      style: AppStyles.elevatedButtonStyle(),
                      child: Text(
                        loginHelper.adminSignUp ? "Sign up as Admin" : "Login",
                        style: TextStyle(color: Colors.white),
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
