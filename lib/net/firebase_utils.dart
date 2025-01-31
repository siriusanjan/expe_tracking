import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, manager, employee,none }

class FirebaseUtils {
  FirebaseUtils._privateConstructor();

  static final FirebaseUtils _instance = FirebaseUtils._privateConstructor();

  factory FirebaseUtils() {
    return _instance;
  }

  Future<void> createUserWithRole(
      String email, String password, String role) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store user role in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': email,
      'role': role, // "admin", "manager", "employee"
    });
  }

  void createAllRoleIfNotCreated() {
    createUserWithRole(
        "admin@example.com", "AdminPass123", UserRole.admin.name);
    createUserWithRole(
        "manager@example.com", "ManagerPass123", UserRole.manager.name);
    createUserWithRole(
        "employee@example.com", "EmployeePass123", UserRole.employee.name);
  }

  Future<UserRole> loginUser(String email, String password) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

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

  void login() async {
    UserRole? role = await loginUser("admin@example.com", "AdminPass123");
    if (role != null) {
      print("Logged in as $role");
    }
  }
}
