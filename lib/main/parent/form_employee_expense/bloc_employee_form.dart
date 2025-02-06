import 'package:expe_traking/main/parent/form_employee_expense/employee_form_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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