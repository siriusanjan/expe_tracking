import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpensesStatusEnum { pending, approved, rejected }

class ExpensesModel {
  String title;
  String description;
  double amount;
  String userId;
  ExpensesStatusEnum expensesStatus;
  String receiptUrl;
  DateTime? timeStamp;
  String authorMail;
  String expId;

  ExpensesModel({
    this.title = "football",
    this.description = "football bill",
    this.amount = 1200.0,
    this.userId = "aa",
    this.expensesStatus = ExpensesStatusEnum.pending,
    this.receiptUrl = "11",
    this.timeStamp,
    this.authorMail = "mailAuthor",
    this.expId = "expId",
  });

  // Convert the ExpensesModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'userId': userId,
      'expensesStatus': expensesStatus.name,
      'receiptUrl': receiptUrl,
      'timeStamp': timeStamp,
      'authorMail': authorMail,
    };
  }

  factory ExpensesModel.fromMap(String docId, Map<String, dynamic> map) {
    return ExpensesModel(
      title: map['title'] ?? "football",
      description: map['description'] ?? "football bill",
      amount: map['amount']?.toDouble() ?? 1200.0,
      userId: map['userId'] ?? "aa",
      expensesStatus: ExpensesStatusEnum.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (map['expensesStatus'] ?? "pending"),
        orElse: () => ExpensesStatusEnum.pending, // Default value if not found
      ),
      receiptUrl: map['receiptUrl'] ?? "11",
      authorMail: map['authorMail'] ?? "authorMail",
      expId: docId,
      timeStamp: (map['timeStamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
