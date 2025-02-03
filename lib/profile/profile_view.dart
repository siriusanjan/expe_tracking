import 'package:expe_traking/net/firebase_utils.dart';
import 'package:expe_traking/on_boarding/login/view/login_sceen.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/base_data_controller.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppValues.backgroundColor,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
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
                  child: Icon(
                    Icons.account_circle,
                    color: AppValues.primaryColor,
                    size: 100,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, top: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            " ${BaseDataController().userCredential!.user!.email!.split('@')[0].toUpperCase()}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            )),
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.mail,
                            color: Colors.grey,
                            size: 15,
                          ),
                          Text(
                              " ${BaseDataController().userCredential!.user!.email!}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                        ],
                      ),
                      // Adds spacing
                      Row(children: [
                        Icon(
                          Icons.settings,
                          color: Colors.grey,
                          size: 15,
                        ),
                        Text(
                            " ${capitalizeFirstLetter(BaseDataController().currentUserRole.name)}",
                            style: TextStyle(
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
                    margin: EdgeInsets.only(top: 16),
                    child: Text(
                      "Basic Information",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ))),
            Container(
                margin: EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12), // Adjust radius here
                ),
                child: CupertinoListTile(
                  title: Text(
                    BaseDataController().currentUserRole == UserRole.employee
                        ? "My Expenses"
                        : "Employee Expenses",
                    style: TextStyle(fontSize: 15),
                  ),
                  subtitle: Text(
                      BaseDataController().currentUserRole == UserRole.employee
                          ? "View You Expenses Details"
                          : "View Employees Expenses Details"),
                  backgroundColor: Colors.transparent,
                  leading: Icon(
                    Icons.attach_money,
                    color: Colors.grey,
                  ),
                  padding: EdgeInsets.all(8),
                )),
            GestureDetector(
              onTap: () async {
                await BaseDataController().clearAllData();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.route, // Named route for LoginScreen
                  (route) => true, // Removes all previous routes
                );
              },
              child: Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(12), // Adjust radius here
                  ),
                  child: CupertinoListTile(
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
