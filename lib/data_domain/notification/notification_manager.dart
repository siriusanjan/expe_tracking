import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:expe_traking/data_domain/utils/app_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../firebase/firebase_utils.dart';
import '../main_expenses/model/expenses_model.dart';
import '../storage/auth_helper.dart';
import '../utils/base_data_controller.dart';

const String accessToken =
    "ya29.a0AXeO80SkgcU6wKwKFa9Xq1Sqx34JC62nrtrD8ysHvCkC9Y2MqHczekhtcad7LDYyL-qYxfV3eQc_CtU5BN4Bcw6RYW7wP9dgq5uS0X8IP8No3AO6fhjuwpDhHoxd_YiH3zbEqJuHELteQgj0j--sFE1yDcalr7XXvc9HdGBTMwaCgYKAS4SAQ8SFQHGX2Mid0sDIxYVta2GAHeRt3S7hw0177";

class NotificationManager {
  NotificationManager._privateConstructor();

  static final NotificationManager _instance =
      NotificationManager._privateConstructor();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationManager() {
    return _instance;
  }

  StreamSubscription<RemoteMessage>? _firebaseStream;
  List<String> adminTokens = [];
  List<String> empToken = [];
  List<String> managerToken = [];

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } else {
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    }
  }

  Future<void> setupFirebaseMessaging(String employeeID) async {
    // Request permission for notifications (iOS)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print("User denied push notifications");
      return;
    }

    if (Platform.isIOS) {
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        print("APNs Token: $apnsToken");

        // Now retrieve the FCM token
        String? fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null) {
          print("FCM Token: $fcmToken");
          await _saveTokenToFireStore(employeeID, fcmToken);
        } else {
          print("❌ FCM token is not available");
        }
      } else {
        print('❌ APNs token not available');
      }
    } else {
      // For Android, get only the FCM token
      String? fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        print("FCM Token: $fcmToken");
        await _saveTokenToFireStore(employeeID, fcmToken);
      } else {
        print("❌ FCM token is not available");
      }
    }

    // Handle Token Refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await _saveTokenToFireStore(employeeID, newToken);
    });
    _firebaseStream
        ?.cancel(); // Cancel any previous listener before setting a new one
    // Handle Incoming Notifications
    _firebaseStream =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _showNotification(message);
    });
  }

  Future<void> registerAdminFCMToken() async {
    await FirebaseMessaging.instance.subscribeToTopic(UserRole.admin.name);
    // String? userId = BaseDataController().userCredential?.user?.uid ?? "";
    //
    // // Get the current user's document
    // DocumentReference userRef =
    //     FirebaseFirestore.instance.collection('users').doc(userId);
    //
    // DocumentSnapshot doc = await userRef.get();
    //
    // // Get the current user's FCM token
    // String? fcmToken = await FirebaseMessaging.instance.getToken();
    //
    // if (fcmToken != null) {
    //   // Add token to user's fcmTokens field if not already present
    //   if (doc.exists) {
    //     adminTokens = [];
    //     var fcmTokensField = doc['fcmTokens'];
    //
    //     // If fcmTokens is a String, wrap it in a list
    //     if (fcmTokensField is String) {
    //       adminTokens.add(fcmTokensField);
    //     }
    //     // If fcmTokens is a List, ensure it's a list of Strings
    //     else if (fcmTokensField is List) {
    //       adminTokens.addAll(List<String>.from(fcmTokensField));
    //     } else {
    //       print("❌ fcmTokens is in an unexpected format.");
    //     }
    //     // Add the new token if it's not already in the list
    //     if (!adminTokens.contains(fcmToken)) {
    //       adminTokens.add(fcmToken);
    //       adminTokens = empToken.toSet().toList();
    //
    //       // Save the token back to Firestore
    //       await userRef.set({
    //         'fcmTokens': adminTokens,
    //       }, SetOptions(merge: true));
    //     }
    //   } else {
    //     // If the user doesn't exist, create a new document with the token
    //     await userRef.set({
    //       'fcmTokens': [],
    //     });
    //   }
    // } else {
    //   print("❌ FCM token is null!");
    // }
  }

  Future<void> registerManagerFCMToken() async {
    await FirebaseMessaging.instance.subscribeToTopic(UserRole.manager.name);

    // String? userId = BaseDataController().userCredential?.user?.uid ?? "";
    //
    // // Get the current user's document
    // DocumentReference userRef =
    //     FirebaseFirestore.instance.collection('users').doc(userId);
    //
    // DocumentSnapshot doc = await userRef.get();
    //
    // // Get the current user's FCM token
    // String? fcmToken = await FirebaseMessaging.instance.getToken();
    //
    // if (fcmToken != null) {
    //   // Add token to user's fcmTokens field if not already present
    //   if (doc.exists) {
    //     managerToken = [];
    //     var fcmTokensField = doc['fcmTokens'];
    //
    //     // If fcmTokens is a String, wrap it in a list
    //     if (fcmTokensField is String) {
    //       managerToken.add(fcmTokensField);
    //     }
    //     // If fcmTokens is a List, ensure it's a list of Strings
    //     else if (fcmTokensField is List) {
    //       managerToken.addAll(List<String>.from(fcmTokensField));
    //     } else {
    //       print("❌ fcmTokens is in an unexpected format.");
    //     }
    //     // Add the new token if it's not already in the list
    //     if (!managerToken.contains(fcmToken)) {
    //       managerToken.add(fcmToken);
    //       managerToken = managerToken.toSet().toList();
    //
    //       // Save the token back to Firestore
    //       await userRef.set({
    //         'fcmTokens': managerToken,
    //       }, SetOptions(merge: true));
    //     }
    //   } else {
    //     // If the user doesn't exist, create a new document with the token
    //     await userRef.set({
    //       'fcmTokens': [],
    //     });
    //   }
    // } else {
    //   print("❌ FCM token is null!");
    // }
  }

  Future<void> _saveTokenToFireStore(String employeeID, String token) async {
    List<String> allTopics = [UserRole.manager.name, UserRole.admin.name];

    // Unsubscribe from all topics first
    for (String topic in allTopics) {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
    if (BaseDataController().currentUserRole == UserRole.admin) {
      registerAdminFCMToken();
    } else if (BaseDataController().currentUserRole == UserRole.manager) {
      registerManagerFCMToken();
    } else if (BaseDataController().currentUserRole == UserRole.employee) {
      await FirebaseMessaging.instance
          .subscribeToTopic(BaseDataController().user?.uid ?? "");
    }
  }

  void _showNotification(RemoteMessage message) async {
    final ExpensesModel expensesModel =
        ExpensesModel.fromMap(message.data["expId"], message.data);
    Map<String, dynamic> messageData = message.data;
    String? myFirebaseToke = await _firebaseMessaging.getToken();
    if (canShowNotification(expensesModel)) {
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        BaseDataController().currentUserRole.name,
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );

      NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin
          .show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
      )
          .then((_) {
        if (BaseDataController().currentUserRole == UserRole.admin) {
          BaseDataController()
              .updateExpenseList(expensesModel, shouldUpdate: true);
          return true;
        }

        if (BaseDataController().currentUserRole == UserRole.employee) {
          BaseDataController()
              .updateExpenseList(expensesModel, shouldUpdate: true);
          return true;
        }
        if (BaseDataController().currentUserRole == UserRole.manager) {
          BaseDataController()
              .updateExpenseList(expensesModel, shouldUpdate: false);
          return true;
        }
      });
    }
  }

  Future<String?> _getAccessToken() async {
    return null;

    // Run gcloud command to get a fresh token
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   String? token = await user.getIdToken();
    //   print("Firebase Access Token: $token");
    //   return token;
    // } else {
    //   print("❌ Error getting access token:");
    //   return accessToken;
    // }
  }

  Future<void> sendNotificationToAdmins(ExpensesModel expense) async {
    final Map<String, dynamic> notificationData = {
      "message": {
        "topic": UserRole.admin.name, // Replace with your topic name
        "notification": {
          "title": "${expense.title} - ${expense.expensesStatus.name}",
          "body":
              "Employee just added ${expense.title} is ${expense.expensesStatus.name}"
        },
        "data": expense.toJsonWithMessageID("")
      }
    };

    try {
      await sendPushNotification(expense, notificationData);
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  Future<void> sendNotificationToManager(ExpensesModel expense) async {
    final Map<String, dynamic> notificationData = {
      "message": {
        "topic": UserRole.manager.name, // Replace with your topic name
        "notification": {
          "title": "${expense.title} - ${expense.expensesStatus.name}",
          "body":
              "Employee just added ${expense.title} is ${expense.expensesStatus.name}"
        },
        "data": expense.toJsonWithMessageID("")
      }
    };

    try {
      await sendPushNotification(expense, notificationData);
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  Future<void> sendNotificationToEmployee(ExpensesModel expense) async {
    final Map<String, dynamic> notificationData = {
      "message": {
        "topic": expense.employeeID, // Replace with your topic name
        "notification": {
          "title": "${expense.title} - ${expense.expensesStatus.name}",
          "body":
              "Your expense item ${expense.title} is ${expense.expensesStatus.name}"
        },
        "data": expense.toJsonWithMessageID(""),
      }
    };

    await sendPushNotification(expense, notificationData);
  }

  Future<void> sendPushNotification(
      ExpensesModel expense, Map<String, dynamic> notificationData) async {
    final String savedSqliteNotifToken =
        await AuthHelper.getSavedNotificationToken();

    String projectId = 'expensetraking-9d192';
    Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $savedSqliteNotifToken",
        },
        body: jsonEncode(notificationData),
      );
      if (response.statusCode == 200) {
        print("Notification sent to ");
      } else {
        print("Error sending notification: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void updateExpenseStatus(ExpensesModel expense) async {
    await FirebaseUtils().updateExpenseStatus(
        expense.expId, expense.expensesStatus.name, expense.updaterMail);
    if (expense.expensesStatus == ExpensesStatusEnum.approved) {
      sendNotificationToAdmins(expense);
    }
    sendNotificationToEmployee(expense);
  }

  bool canShowNotification(ExpensesModel expensesModel) {
    if (BaseDataController().currentUserRole == UserRole.admin &&
        expensesModel.expensesStatus == ExpensesStatusEnum.approved) {
      return true;
    }

    if (BaseDataController().user?.uid == expensesModel.employeeID &&
        BaseDataController().currentUserRole == UserRole.employee) {
      return true;
    }
    if (BaseDataController().currentUserRole == UserRole.manager) {
      return true;
    }
    return false;
  }

  Future<void> removeFireBaseNotificationToken(
      {required String notificationTopicName}) async {
    final currentToken = _firebaseMessaging.getToken();
    String? userId = BaseDataController().user?.uid ?? "";
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    if (BaseDataController().currentUserRole == UserRole.admin) {
      adminTokens.remove(currentToken ?? "");
      await userRef.set({'fcmTokens': adminTokens}, SetOptions(merge: true));
    } else if (BaseDataController().currentUserRole == UserRole.employee) {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(BaseDataController().user?.uid ?? "");
      empToken.remove(currentToken);
      await userRef.set({'fcmTokens': empToken}, SetOptions(merge: true));
    } else if (BaseDataController().currentUserRole == UserRole.manager) {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(BaseDataController().user?.uid ?? "");
      managerToken.remove(currentToken);
      await userRef.set({'fcmTokens': empToken}, SetOptions(merge: true));
    }
    await removeFirebaseMessagingListener(
        notificationTopicName: notificationTopicName);
  }

  // Call this method when the user logs out
  Future<void> removeFirebaseMessagingListener(
      {required String notificationTopicName}) async {
    await unsubscribeFromRoleTopic(
        notificationTopicName: notificationTopicName);
    _firebaseStream?.cancel();
    _firebaseStream = null;
    adminTokens.clear();
    empToken.clear();
    managerToken.clear();
    print("Firebase Messaging listener removed.");
  }

  Future<void> unsubscribeFromRoleTopic(
      {required String notificationTopicName}) async {
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(notificationTopicName);
  }
}
