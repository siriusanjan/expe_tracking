import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployeeMainView extends StatelessWidget {
  static const String route = "employee_screen";

  const EmployeeMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("Employee"),
        ),
      ),
    );
  }
}
