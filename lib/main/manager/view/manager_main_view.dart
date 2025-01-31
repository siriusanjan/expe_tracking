import 'package:expe_traking/utils/AppDialogue.dart';
import 'package:expe_traking/utils/permission_utils.dart';
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
          child: Column(
            children: [
              Text("Manager"),
              ElevatedButton(
                onPressed: () {
                  PermissionUtils.requestPhotoPermission(context);
                },
                child: Text("Upload Photo"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
