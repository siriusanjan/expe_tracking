import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpensesStatusEnum { pending, approved, rejected }

enum ExpenseCategoryEnum {
  travel,
  meals,
  office,
  software,
  training,
  business,
  miscellaneous
}

class ExpensesModel {
  String title;
  String description;
  double amount;
  String employeeID;
  ExpensesStatusEnum expensesStatus;
  String receiptUrl;
  String? timeStamp;
  String authorMail;
  String updaterMail;
  String expId;
  ExpenseCategoryEnum category;

  ExpensesModel({
    this.title = "football",
    this.description = "football bill",
    this.amount = 1200.0,
    this.employeeID = "aa",
    this.expensesStatus = ExpensesStatusEnum.pending,
    this.receiptUrl = "11",
    this.timeStamp,
    this.authorMail = "mailAuthor",
    this.updaterMail = "updaterMail",
    this.expId = "expId",
    this.category = ExpenseCategoryEnum.miscellaneous,
  });

  // Convert the ExpensesModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'employeeID': employeeID,
      'expensesStatus': expensesStatus.name,
      'receiptUrl': receiptUrl,
      'timeStamp': timeStamp, // Convert DateTime to string
      'authorMail': authorMail,
      'updaterMail': updaterMail,
      'expId': expId.toString(),
      'category': category.name.toString(),
    };
  }

  // Convert the ExpensesModel object to a JSON-friendly format
  Map<String, dynamic> toJson() {
    return {
      'title': title.toString(),
      'expensesStatus': expensesStatus.name.toString(),
      'description': description.toString(),
      'amount': amount.toString(),
      'receiptUrl': receiptUrl.toString(),
      'timeStamp': timeStamp, // Convert DateTime to string
      'authorMail': authorMail.toString(),
      'updaterMail': updaterMail.toString(),
      'employeeID': employeeID.toString(),
      'expId': expId.toString(),
      'category': category.name.toString(),
    };
  }

  Map<String, dynamic> toJsonWithMessageID(String messageId) {
    return {
      'title': title.toString(),
      'expensesStatus': expensesStatus.name.toString(),
      'description': description.toString(),
      'amount': amount.toString(),
      'receiptUrl': receiptUrl.toString(),
      'timeStamp': timeStamp, // Convert DateTime to string
      'authorMail': authorMail.toString(),
      'updaterMail': updaterMail.toString(),
      'employeeID': employeeID.toString(),
      'messageID': messageId.toString(),
      'expId': expId.toString(),
      'category': category.name.toString(),
    };
  }

  factory ExpensesModel.fromMap(String docId, Map<String, dynamic> map) {
    return ExpensesModel(
      title: map['title'] ?? "football",
      description: map['description'] ?? "football bill",
      amount: (map['amount'] is String)
          ? double.tryParse(map['amount']) ?? 1200.0
          : (map['amount'] as num?)?.toDouble() ?? 1200.0,
      employeeID: map['employeeID'] ?? "aa",
      expensesStatus: ExpensesStatusEnum.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (map['expensesStatus'] ?? "pending"),
        orElse: () => ExpensesStatusEnum.pending, // Default value if not found
      ),
      receiptUrl: map['receiptUrl'] ?? "11",
      updaterMail: map['updaterMail'] ?? "updaterMail",
      authorMail: map['authorMail'] ?? "authorMail",
      category: ExpenseCategoryEnum.values.firstWhere((e) =>
          e.toString().split('.').last ==
          (map['category'] ?? ExpenseCategoryEnum.miscellaneous.name)),
      expId: docId,
      timeStamp: map['timeStamp'],
    );
  }
}
