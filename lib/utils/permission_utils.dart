import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils{
  static Future<void> requestPhotoPermission(BuildContext context) async {
    PermissionStatus status = await Permission.photos.status;

    if (status.isGranted) {
      print("Permission already granted!");
      return;
    } else if (status.isPermanentlyDenied) {
      // Show alert directing to settings
      showPermissionDialog(context, permanentlyDenied: true);
      return;
    } else {
      // Show explanation dialog before requesting permission
      showPermissionDialog(context);
    }
  }

  static void showPermissionDialog(BuildContext context,
      {bool permanentlyDenied = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            permanentlyDenied ? "Permission Required" : "Photo Access Needed"),
        content: Text(permanentlyDenied
            ? "You have permanently denied access. Please enable it from settings."
            : "This app needs access to your photos to upload images."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (permanentlyDenied) {
                openAppSettings(); // Open settings if permanently denied
              } else {
                PermissionStatus newStatus = await Permission.photos.request();
                if (newStatus.isGranted) {
                  print("Permission granted! Proceed with uploading.");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text("Permission denied! ❌ Unable to upload photos."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(permanentlyDenied ? "Open Settings" : "Allow"),
          ),
        ],
      ),
    );
  }
}