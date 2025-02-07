import 'package:flutter/material.dart';

import 'AppValues.dart';

class AppStyles {
  static ButtonStyle elevatedButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppValues.primaryColor,
      foregroundColor: AppValues.backgroundColor,
      // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 12),
      maximumSize: Size(AppValues.mainScreenWidth * 0.9, 50),
      minimumSize: Size(AppValues.mainScreenWidth * 0.9, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
