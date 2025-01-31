import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, manager, employee, none }

class FirebaseUtils {
  FirebaseUtils._privateConstructor();

  static final FirebaseUtils _instance = FirebaseUtils._privateConstructor();

  factory FirebaseUtils() {
    return _instance;
  }

  Future<void> createUserWithRole(String email, String password, String role,
      {Function? catchErrorMessage}) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((error, s) {
      print("errotfadsf " + error.toString());
      if (catchErrorMessage != null) {
        catchErrorMessage!(error.toString());
      }
    });

    // Store user role in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': email,
      'role': role, // "admin", "manager", "employee"
    }).catchError((e, s) {
      print("error datatkjdklfjakldsjflaksdfma");
      if (catchErrorMessage != null) {
        catchErrorMessage!(e.toString());
      }
    });
  }

  Future<UserRole> loginUser(String email, String password,
      {Function? catchErrorMessage}) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((error) {
      if (catchErrorMessage != null) {
        catchErrorMessage!(error.toString());
      }
    });

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (userDoc.exists) {
      return UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == userDoc['role'],
      ); // "admin", "manager", "employee"
    }
    return UserRole.none;
  }
}
