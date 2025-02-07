import 'package:expe_traking/data_domain/firebase/firebase_utils.dart';
import 'package:expe_traking/data_domain/utils/app_utils.dart';
import 'package:expe_traking/ui_layer/login/login_sceen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data_domain/utils/AppDialogue.dart';
import '../../data_domain/utils/AppValues.dart';
import '../../data_domain/utils/base_data_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppValues.backgroundColor,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 30,
                  )),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(width: 2, color: Colors.grey)),
                  child: const Icon(
                    Icons.account_circle,
                    color: AppValues.primaryColor,
                    size: 100,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10, top: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            " ${BaseDataController().user?.email!.split('@')[0].toUpperCase()}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            )),
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons.mail,
                            color: Colors.grey,
                            size: 15,
                          ),
                          Text(BaseDataController().user?.email ?? "",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      // Adds spacing
                      Row(children: [
                        const Icon(
                          Icons.settings,
                          color: Colors.grey,
                          size: 15,
                        ),
                        Text(
                            " ${capitalizeFirstLetter(BaseDataController().currentUserRole.name)}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w400))
                      ]),
                    ],
                  ),
                )
              ],
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: const Text(
                      "Basic Information",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ))),
            Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // Adjust radius here
                ),
                child: CupertinoListTile(
                  title: Text(
                    BaseDataController().currentUserRole == UserRole.employee
                        ? "My Expenses"
                        : "Employee Expenses",
                    style: const TextStyle(fontSize: 15),
                  ),
                  subtitle: Text(
                      BaseDataController().currentUserRole == UserRole.employee
                          ? "View You Expenses Details"
                          : "View Employees Expenses Details"),
                  backgroundColor: Colors.transparent,
                  leading: const Icon(
                    Icons.attach_money,
                    color: Colors.grey,
                  ),
                  padding: const EdgeInsets.all(8),
                )),
            GestureDetector(
              onTap: () async {
                AppDialogue.showLoadingDialog(context);
                if (await AppUtils.hasInternetConnection(context)) {
                  await BaseDataController()
                      .clearAllDataWithLogout(
                          BaseDataController().user?.email ?? "")
                      .then((_) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      LoginScreen.route, // Named route for LoginScreen
                      (route) => route.settings.name == LoginScreen.route, // Removes all previous routes
                    );
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(12), // Adjust radius here
                  ),
                  child: const CupertinoListTile(
                    title: Text(
                      "Logout",
                      style: TextStyle(fontSize: 15),
                    ),
                    backgroundColor: Colors.transparent,
                    leading: Icon(
                      Icons.login_outlined,
                      color: Colors.grey,
                    ),
                    subtitle: Text("Logout of the app"),
                    padding: EdgeInsets.all(8),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
