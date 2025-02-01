import 'package:expe_traking/on_boarding/login/view/login_sceen.dart';
import 'package:flutter/material.dart';
import '../main/admin/view/admin_main_view.dart';
import '../main/employee/view/employee_main_view.dart';
import '../main/manager/view/manager_main_view.dart';
import '../main/parent/parent_view.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case ParentView.route:
        return MaterialPageRoute(builder: (_) => ParentView());
      case LoginScreen.route:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
