import 'package:flutter_bloc/flutter_bloc.dart';

import 'employee_helper.dart';
enum AdminState{
  initialState,networkState,photoPicked,pickingImage,submittingForm,submittingResulted
}

class BlocAdmin extends Cubit<AdminState>{
  late AdminHelper adminHelper;
  BlocAdmin(super.initialState);
  void changeBlocState(AdminState state){
    emit(state);
  }
}