import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../ui_layer/profile/profile_view.dart';
import '../utils/AppValues.dart';
import 'expense_events.dart';

class ParentHelper {
  ParentHelper();

  void openAddBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
        useSafeArea: true,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
              height: AppValues.mainScreenHeight * 0.5,
              decoration: BoxDecoration(
                  color: AppValues.backgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16))),
              padding: const EdgeInsets.all(6),
              child: ProfileView());
        });
  }


}
