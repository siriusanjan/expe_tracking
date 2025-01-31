import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppDialogue {
  // static void showSettingsDialog(BuildContext context, String permissionType) {
  //   Platform.isAndroid
  //       ? showDialog(
  //           context: context,
  //           builder: (BuildContext context) => AlertDialog(
  //             title: Text('$permissionType Permission Required'),
  //             content: Text(
  //                 'Please enable $permissionType access in the app settings to continue.'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   await openAppSettings();
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text('Open Settings'),
  //               ),
  //             ],
  //           ),
  //         )
  //       : showCupertinoDialog(
  //           context: context,
  //           builder: (BuildContext context) => CupertinoAlertDialog(
  //             title: Text('$permissionType Permission Required'),
  //             content: Text(
  //                 'Please enable $permissionType access in the app settings to continue.'),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () async {
  //                   await openAppSettings();
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text('Open Settings'),
  //               ),
  //             ],
  //           ),
  //         );
  // }

  static void showLoadingDialog(BuildContext context, {String? text}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent dialog from closing when tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          // Makes the background transparent
          child: Container(
            alignment: Alignment.center,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                // Loading spinner
                SizedBox(height: 20),
                Text(
                  text ?? 'Please Wait...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }// Function to show the full-screen loading dialog

static void noUserFoundSnackBar({required BuildContext context}){
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("No user found!"),
      backgroundColor: Colors.red,
    ),
  );
  return;
}
}
