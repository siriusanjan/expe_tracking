import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expe_traking/utils/base_data_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main/parent/model/expenses_model.dart';

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
    BaseDataController().userCredential = userCredential;

    if (userDoc.exists) {
      return UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == userDoc['role'],
      ); // "admin", "manager", "employee"
    }
    return UserRole.none;
  }

  Future<void> submitExpenses(ExpensesModel model, Function result) async {
    try {
      await FirebaseFirestore.instance
          .collection("expenses")
          .add(model.toMap());
      result('Expense submitted successfully!', true);
    } catch (e) {
      result('Error submitting expense: $e', true);
    }
  }

  /// update by manager
  Future<void> updateExpenseStatus(String expenseId, String status,String updaterMail) async {
    await FirebaseFirestore.instance
        .collection("expenses")
        .doc(expenseId)
        .update({
        "expensesStatus": status, // "approved" or "rejected"
        "updaterMail": updaterMail, // "approved" or "rejected"
    });
  }

  /// get user wise expenses
  Future<List<QueryDocumentSnapshot>> getUserExpenses(String employeeID) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("expenses")
        .where("employeeID", isEqualTo: employeeID)
        .get();
    return query.docs;
  }

  /// get all expenses
  Future<List<QueryDocumentSnapshot>> getAllExpenses() async {
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection("expenses").get();
    return query.docs;
  }

  /// get status wise expenses
  Future<List<QueryDocumentSnapshot>> getExpensesByStatus(String status) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("expenses")
        .where("expensesStatus", isEqualTo: status)
        .get();
    return query.docs;
  }
}
