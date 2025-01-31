import 'package:expe_traking/net/firebase_utils.dart';

class BaseDataController {
  BaseDataController._privateConstructor();

  static final BaseDataController _instance =
      BaseDataController._privateConstructor();

  UserRole currentUserRole = UserRole.none;

  factory BaseDataController() {
    return _instance;
  }

  Future<void> loginIn(
      {required String email,
      required String password,
      Function? catchErrorMessage}) async {
    currentUserRole = await FirebaseUtils()
        .loginUser(email, password, catchErrorMessage: catchErrorMessage);
  }

  Future<void> createUserWithRole(
      {required String email,
      required String password,
      required UserRole userRole,Function? catchErrorMessage}) async {
    await FirebaseUtils().createUserWithRole(email, password, userRole.name, catchErrorMessage: catchErrorMessage);
  }
}
