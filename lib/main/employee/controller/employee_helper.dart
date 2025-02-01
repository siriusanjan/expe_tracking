import 'dart:io';

import 'package:expe_traking/main/employee/controller/bloc_employee.dart';
import 'package:expe_traking/main/employee/view/widget/expense_form.dart';
import 'package:expe_traking/utils/AppDialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/AppValues.dart';
import '../../../utils/permission_utils.dart';

class EmployeeHelper {
  BlocEmployee blocEmployee = BlocEmployee(EmployeeState.initialState);
  File? finalPickedFile;

  // Focus nodes to manage focus between fields
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode amountFocusNode = FocusNode();

  EmployeeHelper();

  void openAddBottomSheet({required BuildContext blocContext}) {
    showModalBottomSheet(
        context: blocContext,
        isScrollControlled: true,
        builder: (dialogContext) {
          return BlocProvider<BlocEmployee>.value(
              value: blocEmployee,
              child: Container(
                  height: AppValues.mainScreenHeight * 0.8,
                  decoration: BoxDecoration(
                      color: AppValues.backgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  padding: const EdgeInsets.all(16),
                  child: ExpenseForm()));
        });
  }

  Future<void> pickImage(BuildContext context) async {
    AppDialogue.showLoadingDialog(context);
    blocEmployee.changeBlocState(EmployeeState.pickingImage);

    PermissionUtils.requestPhotoPermission(context, Permission.photos,
        (isGranted) async {
      if (isGranted) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        Navigator.pop(context);
        if (pickedFile != null) {
          finalPickedFile = File(pickedFile.path);
          blocEmployee.changeBlocState(EmployeeState.photoPicked);
        }
      }
    });
  }
}
