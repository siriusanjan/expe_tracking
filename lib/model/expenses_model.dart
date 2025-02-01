class ExpensesModel {
  final String title;
  final String description;
  final double amount;
  final String userId;
  final String expensesStatus;
  final String receiptUrl;

  ExpensesModel({
    this.title = "football",
    this.description = "football bill",
    this.amount = 1200.0,
    this.userId = "aa",
    this.expensesStatus = "pending",
    this.receiptUrl = "11",
  });

  // Convert the ExpensesModel object to a map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'amount': amount,
      'userId': userId,
      'expensesStatus': expensesStatus,
      'receiptUrl': receiptUrl,
    };
  }

  factory ExpensesModel.fromMap(Map<String, dynamic> map) {
    return ExpensesModel(
      title: map['title'] ?? "football",
      description: map['description'] ?? "football bill",
      amount: map['amount']?.toDouble() ?? 1200.0,
      userId: map['userId'] ?? "aa",
      expensesStatus: map['expensesStatus'] ?? "pending",
      receiptUrl: map['receiptUrl'] ?? "11",
    );
  }
}
