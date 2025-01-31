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
      {required String email, required String password}) async {
    currentUserRole = await FirebaseUtils().loginUser(email, password);
  }
}
