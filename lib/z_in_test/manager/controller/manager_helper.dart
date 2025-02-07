import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bloc_manager.dart';

class ManagerHelper {
  BlocManager blocAdmin = BlocManager(ManagerState.initialState);


  ManagerHelper();



}
