import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main_expenses/model/expenses_model.dart';
import '../utils/base_data_controller.dart';

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
        catchErrorMessage(error.toString());
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
        catchErrorMessage(e.toString());
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
        catchErrorMessage(error.toString());
      }
    });

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();
    BaseDataController().user = userCredential.user;

    if (userDoc.exists) {
      return UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == userDoc['role'],
      ); // "admin", "manager", "employee"
    }
    return UserRole.none;
  }

  Future<void> submitExpenses(ExpensesModel model, Function result) async {
    try {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection("expenses")
          .add(model.toMap());
      result('Expense submitted successfully!', docRef.id.toString(), true);
    } catch (e) {
      result('Error submitting expense: $e', true);
    }
  }

  /// update by manager
  Future<void> updateExpenseStatus(
      String expenseId, String status, String updaterMail) async {
    await FirebaseFirestore.instance
        .collection("expenses")
        .doc(expenseId)
        .update({
      "expensesStatus": status, // "approved" or "rejected"
      "expId": expenseId, // "approved" or "rejected"
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

  /// filter list

  Future<List<QueryDocumentSnapshot>> getFilteredExpensesFromDatabase({
    required String employeeID,
    DateTime? startDate,
    DateTime? endDate,
    ExpensesStatusEnum? expensesStatusFilter,
    ExpenseCategoryEnum? expenseCategoryEnum,
    String? employeeEmailFilter,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection("expenses")
        .where("employeeID", isEqualTo: employeeID);

    // Apply filters directly in Firestore
    if (startDate != null) {
      query = query.where("timeStamp",
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where("timeStamp",
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }
    if (expenseCategoryEnum != null) {
      query = query.where("expenseCategoryEnum",
          isEqualTo: expenseCategoryEnum.name);
    }

    if (employeeEmailFilter != null) {
      query = query.where("authorMail", isEqualTo: employeeEmailFilter);
    }

    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs;
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
