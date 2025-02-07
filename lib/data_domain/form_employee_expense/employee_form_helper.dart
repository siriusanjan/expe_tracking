import 'dart:io';

import 'package:expe_traking/data_domain/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../ui_layer/employee_form/expense_form.dart';
import '../main_expenses/model/expenses_model.dart';
import '../notification/notification_manager.dart';
import '../utils/AppDialogue.dart';
import '../utils/AppValues.dart';
import '../utils/base_data_controller.dart';
import '../utils/permission_utils.dart';
import 'bloc_employee_form.dart';

class EmployeeFormHelper {
  BlocEmployeeForm blocEmployee =
      BlocEmployeeForm(EmployeeFormState.initialState);
  File? finalPickedFile;

  // Focus nodes to manage focus between fields
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode amountFocusNode = FocusNode();
  ExpensesModel expensesModel = ExpensesModel();
  ExpenseCategoryEnum expenseCategoryEnum = ExpenseCategoryEnum.miscellaneous;

  EmployeeFormHelper();

  void openAddBottomSheet({required BuildContext blocContext}) {
    showModalBottomSheet(
        context: blocContext,
        isScrollControlled: true,
        builder: (dialogContext) {
          return BlocProvider<BlocEmployeeForm>.value(
              value: blocEmployee,
              child: Container(
                  height: AppValues.mainScreenHeight * 0.65,
                  decoration: const BoxDecoration(
                      color: AppValues.backgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  padding: const EdgeInsets.all(16),
                  child: const ExpenseForm()));
        });
  }

  Future<void> pickImage(BuildContext context) async {
    AppDialogue.showLoadingDialog(context);
    blocEmployee.changeBlocState(EmployeeFormState.pickingImage);

    PermissionUtils.requestPhotoPermission(context, Permission.photos,
        (isGranted) async {
      if (isGranted) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        Navigator.pop(context);
        if (pickedFile != null) {
          finalPickedFile = File(pickedFile.path);
          blocEmployee.changeBlocState(EmployeeFormState.photoPicked);
        }
      }else{
        Navigator.pop(context);
      }
    });
  }

  Future<void> submitForm(BuildContext context) async {
    AppDialogue.showLoadingDialog(context);
    blocEmployee.changeBlocState(EmployeeFormState.submittingForm);
    expensesModel.timeStamp = DateTime.now().toString();
    if (finalPickedFile != null) {
      if (await AppUtils.hasInternetConnection(context)) {
        BaseDataController()
            .uploadReceipt(finalPickedFile!)
            .then((receiptUrl) async {
          if (receiptUrl != null) {
            expensesModel.receiptUrl = receiptUrl;
            BaseDataController().addExpense(expensesModel,
                (message, docID, isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              if (isSuccess) {
                blocEmployee
                    .changeBlocState(EmployeeFormState.submittingResulted);
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                blocEmployee
                    .changeBlocState(EmployeeFormState.submittingResulted);
                Navigator.pop(context);
              }
            });
          } else {
            // Navigator.pop(context);
            // blocEmployee.changeBlocState(EmployeeState.submittingResulted);
            //
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('Unable to upload receipt')),
            // );
            expensesModel.receiptUrl =
                "https://images.unsplash.com/photo-1546198632-9ef6368bef12?q=80&w=3270&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
            BaseDataController().addExpense(expensesModel,
                (message, docID, isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              if (isSuccess) {
                blocEmployee
                    .changeBlocState(EmployeeFormState.submittingResulted);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  expensesModel.expId = docID;
                  NotificationManager()
                      .sendNotificationToManager(expensesModel);
                  BaseDataController().updateExpenseList(expensesModel);
                });
                Navigator.pop(context);
                Navigator.pop(context);
              } else {
                blocEmployee
                    .changeBlocState(EmployeeFormState.submittingResulted);
                Navigator.pop(context);
              }
            });
          }
        });
      } else {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);

      AppDialogue.noUserFoundSnackBar(
          context: context, message: "No File found");
    }
  }
}
