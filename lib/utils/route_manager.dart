import 'package:flutter/material.dart';
import '../main/admin/view/admin_main_view.dart';
import '../main/employee/view/employee_main_view.dart';
import '../main/manager/view/manager_main_view.dart';

class RouteManager {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;

    switch (settings.name) {
      case AdminMainView.route:
        return MaterialPageRoute(builder: (_) => const AdminMainView());
      case ManagerMainView.route:
        return MaterialPageRoute(builder: (_) => const ManagerMainView());
      case EmployeeMainView.route:
        return MaterialPageRoute(builder: (_) => const EmployeeMainView());
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
