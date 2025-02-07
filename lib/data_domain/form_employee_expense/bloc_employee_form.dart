import 'package:flutter_bloc/flutter_bloc.dart';

import 'employee_form_helper.dart';
enum EmployeeFormState{
  initialState,networkState,photoPicked,pickingImage,submittingForm,submittingResulted
}

class BlocEmployeeForm extends Cubit<EmployeeFormState>{
  late EmployeeFormHelper employeeHelper;
  BlocEmployeeForm(super.initialState);
  void changeBlocState(EmployeeFormState state){
    emit(state);
  }


}