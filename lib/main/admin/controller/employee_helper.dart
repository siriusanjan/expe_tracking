import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expe_traking/main/parent/form_employee_expense/expense_form.dart';
import 'package:expe_traking/utils/AppDialogue.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/AppValues.dart';
import '../../../utils/permission_utils.dart';
import '../../parent/model/expenses_model.dart';
import 'bloc_employee.dart';

class AdminHelper {
  BlocAdmin blocAdmin = BlocAdmin(AdminState.initialState);


 AdminHelper();



}
