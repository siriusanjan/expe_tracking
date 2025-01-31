import 'package:flutter/material.dart';

class AdminMainView extends StatelessWidget {
  static const String route = "admin_screen";

  const AdminMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: Center(child: Text("Admin"),),),
    );
  }
}
