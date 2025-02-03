import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:expe_traking/main/parent/model/expenses_model.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../net/firebase_utils.dart';
import '../utils/base_data_controller.dart';

const String accessToken =
    "ya29.a0AXeO80RIzlhTKn70LlqZpJNGeFEaGZOIk1SMfkTunWSWgLDS21JKkG7qgCHamXit526h9ADwHwdUhag6XtE0NajQWYabf7FCIyCjIPbGVHMXv6YTmHpqpsvrgaXN2S0B7KTuDqWxgDIvQSjIQNq8P-CwHOcITXxik4IU4De4bwaCgYKAesSAQ8SFQHGX2Mi3Qj-ZqeOmgCyntP8des2Mg0177";

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

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    if (Platform.isAndroid) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final InitializationSettings initializationSettings =
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
    String? userId = BaseDataController().userCredential?.user?.uid ?? "";

    // Get the current user's document
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    DocumentSnapshot doc = await userRef.get();

    // Get the current user's FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      // Add token to user's fcmTokens field if not already present
      if (doc.exists) {
        adminTokens = [];
        var fcmTokensField = doc['fcmTokens'];

        // If fcmTokens is a String, wrap it in a list
        if (fcmTokensField is String) {
          adminTokens.add(fcmTokensField);
        }
        // If fcmTokens is a List, ensure it's a list of Strings
        else if (fcmTokensField is List) {
          adminTokens.addAll(List<String>.from(fcmTokensField));
        } else {
          print("❌ fcmTokens is in an unexpected format.");
        }
        // Add the new token if it's not already in the list
        if (!adminTokens.contains(fcmToken)) {
          adminTokens.add(fcmToken);
          adminTokens = empToken.toSet().toList();

          // Save the token back to Firestore
          await userRef.set({
            'fcmTokens': adminTokens,
          }, SetOptions(merge: true));
        }
      } else {
        // If the user doesn't exist, create a new document with the token
        await userRef.set({
          'fcmTokens': [],
        });
      }
    } else {
      print("❌ FCM token is null!");
    }
  }

  Future<void> _saveTokenToFireStore(String employeeID, String token) async {
    if (BaseDataController().currentUserRole == UserRole.admin) {
      registerAdminFCMToken();
      print("registerForAdmin ");
    } else if (BaseDataController().currentUserRole == UserRole.employee) {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(BaseDataController().userCredential?.user?.uid ?? "");

      DocumentSnapshot doc = await userRef.get();

// If the document exists and the fcmTokens field is present
      if (doc.exists && doc.data() != null) {
        var fcmTokensField = doc['fcmTokens'];

        // If fcmTokens is a String, wrap it in a list
        if (fcmTokensField is String) {
          empToken.add(fcmTokensField);
        }
        // If fcmTokens is already a List, add all items to the list
        else if (fcmTokensField is List) {
          empToken.addAll(List<String>.from(fcmTokensField));
        } else {
          print("❌ fcmTokens is in an unexpected format.");
        }
      }
      if (!empToken.contains(token)) {
        empToken.add(token);
        print("myEmpTokens " + empToken.toString());
        AppValues.myNotificationToken = token;
      }
      empToken = empToken.toSet().toList();
      await userRef.set({'fcmTokens': empToken}, SetOptions(merge: true));
    }
  }

  void _showNotification(RemoteMessage message) async {
    final ExpensesModel expensesModel =
        ExpensesModel.fromMap(null, message.data);
    Map<String, dynamic> messageData = message.data;
    String? myFirebaseToke = await _firebaseMessaging.getToken();
    if (canShowNotification(expensesModel) &&
        messageData['messageID'] == myFirebaseToke) {
      print("mySendJSon "+message.data.toString());
      print("myData id "+expensesModel.expId.toString());

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin
          .show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
      )
          .then((_) {
        if (BaseDataController().currentUserRole == UserRole.admin &&
            expensesModel.expensesStatus == ExpensesStatusEnum.approved) {
          BaseDataController()
              .updateExpenseList(expensesModel, shouldUpdate: true);
          return true;
        }

        if (BaseDataController().userCredential?.user?.uid ==
                expensesModel.employeeID &&
            BaseDataController().currentUserRole == UserRole.employee) {
          BaseDataController()
              .updateExpenseList(expensesModel, shouldUpdate: true);
          return true;
        }
      });
    } else {
      print("cannotShowthe nnotification");
    }
  }

  Future<String?> _getAccessToken() async {
    // Run gcloud command to get a fresh token
    var result = await Process.run(
        'gcloud', ['auth', 'application-default', 'print-access-token']);

    if (result.exitCode == 0) {
      return result.stdout.trim();
    } else {
      print("❌ Error getting access token: ${result.stderr}");
      return accessToken;
    }
  }

  Future<void> sendNotificationToAdmins(ExpensesModel expense) async {
    // Get all admin users
    QuerySnapshot adminsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin') // Get only admin users
        .get();

    List<String> tokens = [];

    for (var admin in adminsSnapshot.docs) {
      try {
        // Check if 'fcmTokens' exists and is a list
        if (admin.data() != null) {
          var fcmTokensField = admin['fcmTokens'];

          // If fcmTokens is a single string, wrap it in a list
          if (fcmTokensField is String) {
            tokens.add(fcmTokensField); // Add the single string token
          } else if (fcmTokensField is List) {
            // If it's already a list of strings, add all tokens
            tokens.addAll(List<String>.from(fcmTokensField));
          } else {
            print("❌ fcmTokens is in an unexpected format.");
          }
        } else {
          print("❌ No fcmTokens found for user ${admin.id}");
        }
      } catch (e) {
        print(
            "Error reading FCM tokens for admin ${admin.id}: " + e.toString());
      }
    }

    if (tokens.isEmpty) {
      print("❌ No FCM tokens found for admin users");
      return;
    }

    // Send notifications to all admin tokens
    for (String token in tokens) {
      final Map<String, dynamic> notificationData = {
        "message": {
          "token": token,
          "notification": {
            "title": "${expense.title} - ${expense.expensesStatus.name}",
            "body":
                "Your expense item ${expense.title} is ${expense.expensesStatus.name}"
          },
          "data": expense.toJson()
        }
      };

      try {
        await sendPushNotification(expense, notificationData);
      } catch (e) {
        print("Error sending notification: $e");
      }
    }
  }

  Future<void> sendNotificationToEmployee(ExpensesModel expense) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(expense.employeeID)
        .get();
    if (!userDoc.exists || userDoc['fcmTokens'] == null) {
      print("❌ No FCM tokens found for user ${expense.employeeID}");
      return;
    }

    List<String> tokens = userDoc['fcmTokens'] is String
        ? [userDoc['fcmTokens']]
        : List<String>.from(userDoc['fcmTokens']);

    if (tokens.isEmpty) {
      print("❌ No FCM tokens found for admin users");
      return;
    }
    print("myuserNtfToken " + tokens.length.toString());

    // Send notifications to all admin tokens
    for (String token in tokens) {
      print("tokesn " + token.toString());
      final Map<String, dynamic> notificationData = {
        "message": {
          "token": token,
          "notification": {
            "title": "${expense.title} - ${expense.expensesStatus.name}",
            "body":
                "Your expense item ${expense.title} is ${expense.expensesStatus.name}"
          },
          "data": expense.toJsonWithMessageID(token),
        }
      };
      print("mySendJSon "+expense.toJsonWithMessageID(token.toString()).toString());
      await sendPushNotification(expense, notificationData);
    }
  }

  Future<void> sendPushNotification(
      ExpensesModel expense, Map<String, dynamic> notificationData) async {
    String projectId = 'expensetraking-9d192';
    Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode(notificationData),
      );
      if (response.statusCode == 200) {
        print("✅ Notification sent to ");
      } else {
        print("❌ Error sending notification: ${response.body}");
      }
    } catch (e) {
      print("❌ Error: $e");
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

    if (BaseDataController().userCredential?.user?.uid ==
            expensesModel.employeeID &&
        BaseDataController().currentUserRole == UserRole.employee) {
      return true;
    }
    return false;
  }

  Future<void> removeFireBaseNotificationToken() async {
    final currentToken = _firebaseMessaging.getToken();
    String? userId = BaseDataController().userCredential?.user?.uid ?? "";
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    if (BaseDataController().currentUserRole == UserRole.admin) {
      adminTokens.remove(currentToken ?? "");
      await userRef.set({'fcmTokens': adminTokens}, SetOptions(merge: true));
    } else if (BaseDataController().currentUserRole == UserRole.employee) {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(BaseDataController().userCredential?.user?.uid ?? "");
      empToken.remove(currentToken);
      await userRef.set({'fcmTokens': empToken}, SetOptions(merge: true));
    }
    removeFirebaseMessagingListener();
  }

  // Call this method when the user logs out
  void removeFirebaseMessagingListener() {
    _firebaseStream?.cancel();
    _firebaseStream = null;
    print("✅ Firebase Messaging listener removed.");
  }
}
