import 'package:expe_traking/utils/AppValues.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController textEditingController;
  final TextInputType? keyboardType;
  final String validatorErrorString;
  final bool obscure;

  const TextFieldWidget(
      {super.key,
      required this.hintText,
      required this.icon,
      required this.textEditingController,
      this.keyboardType = TextInputType.text,
      this.obscure = false,
      required this.validatorErrorString});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: (value) {
        if ((value == null || value.isEmpty)) {
          return validatorErrorString;
        } else {
          if (keyboardType == TextInputType.number &&
              double.tryParse(value!) == null) {
            return validatorErrorString;
          } else if (keyboardType == TextInputType.emailAddress &&
              !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value!)) {
            return validatorErrorString;
          } else if (keyboardType == TextInputType.visiblePassword &&
              value!.length < 6) {
            return validatorErrorString;
          } else {
            return null;
          }
        }
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppValues.primaryColor),
        // Icon on the left
        filled: true,
        fillColor: Colors.white,
        // Background color

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
          borderSide: BorderSide.none, // No border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.blueAccent, width: 2), // Border on focus
        ),
        contentPadding:
            EdgeInsets.symmetric(vertical: 16, horizontal: 20), // Padding
      ),
      style: TextStyle(fontSize: 16, color: Colors.black), // Text styling
    );
  }
}
