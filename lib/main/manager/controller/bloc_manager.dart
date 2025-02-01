import 'package:expe_traking/main/admin/controller/employee_helper.dart';
import 'package:expe_traking/main/employee/controller/employee_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'manager_helper.dart';
enum ManagerState{
  initialState,networkState,photoPicked,pickingImage,submittingForm,submittingResulted
}

class BlocManager extends Cubit<ManagerState>{
  late ManagerHelper managerHelper;
  BlocManager(super.initialState);
  void changeBlocState(ManagerState state){
    emit(state);
  }


}