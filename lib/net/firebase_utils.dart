import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUtils {


  Future<void> createUserWithRole(String email, String password,
      String role) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store user role in Firestore
    await FirebaseFirestore.instance.collection('users').doc(
        userCredential.user!.uid).set({
      'email': email,
      'role': role, // "admin", "manager", "employee"
    });
  }

  void createAllRoleIfNotCreated() {
    createUserWithRole("admin@example.com", "AdminPass123", "admin");
    createUserWithRole("manager@example.com", "ManagerPass123", "manager");
    createUserWithRole("employee@example.com", "EmployeePass123", "employee");git
  }

}