import 'package:expe_traking/main/employee/controller/employee_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
enum EmployeeState{
  initialState,networkState,photoPicked,pickingImage
}

class BlocEmployee extends Cubit<EmployeeState>{
  late EmployeeHelper employeeHelper;
  BlocEmployee(super.initialState);
  void changeBlocState(EmployeeState state){
    emit(state);
  }


}