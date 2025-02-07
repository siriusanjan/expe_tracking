import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'AppDialogue.dart';

class AppUtils {
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Function to format DateTime
  static Future<bool> hasInternetConnection(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return true;
    } else {
      AppDialogue.noUserFoundSnackBar(
          context: context, message: "No Internet connection");
      return false;
    }
  }

  static String formatDate(String timeStampString) {
    DateTime date = DateTime.parse(timeStampString);
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      // Today
      return "Today ${DateFormat('HH:mm').format(date)}";
    } else if (difference == 1) {
      // Yesterday
      return "Yesterday ${DateFormat('HH:mm').format(date)}";
    } else if (difference <= 10) {
      // Last 10 days
      return "$difference days ago";
    } else {
      // Default format for older dates
      return DateFormat("dd/MM/yyyy HH:mm").format(date);
    }
  }

  static String formatDollor(double num) {
    if (num >= 1e12) {
      return "${(num / 1e12).toStringAsFixed(1)}T"; // Trillion
    } else if (num >= 1e9) {
      return "${(num / 1e9).toStringAsFixed(1)}B"; // Billion
    } else if (num >= 1e6) {
      return "${(num / 1e6).toStringAsFixed(1)}M"; // Million
    } else if (num >= 1e3) {
      return "${(num / 1e3).toStringAsFixed(1)}K"; // Thousand
    } else {
      return num.toStringAsFixed(0); // No formatting needed
    }
  }
}
