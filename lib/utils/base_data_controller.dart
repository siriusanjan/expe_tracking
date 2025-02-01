import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../main/parent/model/expenses_model.dart';

class BaseDataController {
  BaseDataController._privateConstructor();

  static final BaseDataController _instance =
      BaseDataController._privateConstructor();

  UserRole currentUserRole = UserRole.none;
  late UserCredential? userCredential;

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
      required UserRole userRole,
      Function? catchErrorMessage}) async {
    await FirebaseUtils().createUserWithRole(email, password, userRole.name,
        catchErrorMessage: catchErrorMessage);
  }

  /// added by user
  Future<void> addExpense(ExpensesModel model, Function result) async {
    await FirebaseUtils().submitExpenses(model, result);
  }

  /// update by manager
  Future<void> updateExpenseStatus(String expenseId, String status) async {
    return FirebaseUtils().updateExpenseStatus(expenseId, status);
  }

  /// get user wise expenses
  Future<List<ExpensesModel>> getAllExpenses() async {
    final List<QueryDocumentSnapshot> data =
        await FirebaseUtils().getAllExpenses();
    return data
        .map((doc) =>
            ExpensesModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// get user wise expenses
  Future<List<ExpensesModel>> getUserExpenses(String userId) async {
    final List<QueryDocumentSnapshot> data =
        await FirebaseUtils().getUserExpenses(userId);
    return data
        .map((doc) =>
            ExpensesModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// get user wise expenses
  Future<List<ExpensesModel>> getExpensesByStatus(String status) async {
    final List<QueryDocumentSnapshot> data =
        await FirebaseUtils().getExpensesByStatus(status);
    return data
        .map((doc) =>
            ExpensesModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String?> uploadReceipt(File imageFile) async {
    try {
      String fileName = "receipts/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  void clearAllData() {
    currentUserRole = UserRole.none;
    userCredential = null;
  }
}
