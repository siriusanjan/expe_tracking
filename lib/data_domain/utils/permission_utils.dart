import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<void> requestPhotoPermission(
      BuildContext context, Permission permission, Function isGranted) async {
    PermissionStatus status = await permission.status;

    if (status.isGranted) {
      isGranted(true);
      return;
    } else if (status.isPermanentlyDenied) {
      // Show alert directing to settings

      showPermissionDialog(context, permission, isGranted,
          permanentlyDenied: true);
      return;
    } else {
      // Show explanation dialog before requesting permission
      showPermissionDialog(
        context,
        permission,
        isGranted,
      );
    }
  }

  static void showPermissionDialog(
      BuildContext context, Permission permission, Function isGranted,
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
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (permanentlyDenied) {
                isGranted(false);

                openAppSettings(); // Open settings if permanently denied
              } else {
                PermissionStatus newStatus = await permission.request();
                if (newStatus.isGranted) {
                  print("Permission granted! Proceed with uploading.");
                  isGranted(true);
                } else {
                  isGranted(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
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
