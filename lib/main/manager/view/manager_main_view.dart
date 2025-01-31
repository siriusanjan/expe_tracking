import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ManagerMainView extends StatelessWidget {
  static const String route = "manager_screen";

  const ManagerMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text("Manager"),
        ),
      ),
    );
  }
}
