import 'package:flutter/material.dart';

import '../../ui_layer/profile/profile_view.dart';
import '../firebase/remote_config_service.dart';
import '../notification/notification_manager.dart';
import '../utils/AppValues.dart';
import '../utils/base_data_controller.dart';

class ParentHelper {
  DateTime? lastPressed;
  RemoteConfigService _remoteConfigService = RemoteConfigService();

  ParentHelper() {
    if (BaseDataController().user?.uid != null) {
      print("managingNotification ");
      NotificationManager()
          .setupFirebaseMessaging(BaseDataController().user?.uid ?? "");
    }
    try {
      _remoteConfigService.fetchConfig();
    } catch (e) {
      print("reomteE " + e.toString());
    }
  }

  void openAddBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
              height: AppValues.mainScreenHeight * 0.5,
              decoration: const BoxDecoration(
                  color: AppValues.backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              padding: const EdgeInsets.all(6),
              child: const ProfileView());
        });
  }

  bool canExit(BuildContext context) {
    final now = DateTime.now();
    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(milliseconds: 400),
        ),
      );
      return false; // Wait for double press
    } else {
      lastPressed = null;
    }
    return true;
  }
}
