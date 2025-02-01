import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expe_traking/net/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
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
  Future<void> addExpense(String title, String description, double amount,
      String userId, String receiptUrl) async {
    await FirebaseFirestore.instance.collection("expenses").add({
      "title": title,
      "description": description,
      "amount": amount,
      "userId": userId,
      "receiptUrl": receiptUrl,
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
  /// update by manager
  Future<void> updateExpenseStatus(String expenseId, String status) async {
    return FirebaseUtils().updateExpenseStatus(expenseId, status);
  }

  /// get user wise expenses
  Future<List<QueryDocumentSnapshot>> getUserExpenses(String userId) async {
    return FirebaseUtils().getUserExpenses(userId);
  }  /// get user wise expenses
  Future<List<QueryDocumentSnapshot>> getExpensesByStatus(String status) async {
    return FirebaseUtils().getExpensesByStatus(status);
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
  void clearAllData(){
    currentUserRole=UserRole.none;
    userCredential=null;
  }
}
