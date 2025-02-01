import 'package:expe_traking/main/admin/controller/employee_helper.dart';
import 'package:expe_traking/main/employee/controller/employee_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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