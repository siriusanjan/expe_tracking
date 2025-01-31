import 'package:expe_traking/on_boarding/login/controller/login_helper.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
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
                    TextFormField(
                      autofocus: false,
                      controller: loginHelper.emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: loginHelper.passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                      autofocus: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(

                      onPressed: () {
                        loginHelper.processSign(context: context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppValues.primaryColor
                      ),
                      child: Text(loginHelper.adminSignUp
                          ? "Sign up as Admin"
                          : "Login",style: TextStyle(color: Colors.white),),
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
}
