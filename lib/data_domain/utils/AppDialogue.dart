
import 'package:flutter/material.dart';

class AppDialogue {


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
                const CircularProgressIndicator(
                  color: Colors.black,
                ),
                // Loading spinner
                const SizedBox(height: 20),
                Text(
                  text ?? 'Please Wait...',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  } // Function to show the full-screen loading dialog

  static void noUserFoundSnackBar({required BuildContext context,required String message,Color? color=Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
    return;
  }
}
