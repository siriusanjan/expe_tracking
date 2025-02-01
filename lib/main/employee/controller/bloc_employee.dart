import 'package:flutter_bloc/flutter_bloc.dart';
enum EmployeeState{
  initialState,networkState,
}
class BlocEmployee extends Cubit<EmployeeState>{
  BlocEmployee(super.initialState);

}