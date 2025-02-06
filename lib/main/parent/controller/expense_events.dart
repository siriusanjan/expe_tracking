import 'package:expe_traking/main/parent/model/expenses_model.dart';

abstract class ExpenseListEvent {}

class FetchExpensesEvent extends ExpenseListEvent {}
class LoadMoreExpensesEvent extends ExpenseListEvent {}

class UpdateExpenseEvent extends ExpenseListEvent {
  final ExpensesModel expense;
  final bool shouldUpdate;
  final Function updatedIndex;

  UpdateExpenseEvent(
      {required this.expense,
      this.shouldUpdate = false,
      required this.updatedIndex});
}

class FilterExpensesEvent extends ExpenseListEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final ExpensesStatusEnum? expensesStatusFilter;
  final ExpenseCategoryEnum? expenseCategoryEnum;
  final String? employeeEmailFilter;

  FilterExpensesEvent(
      {this.startDate,
      this.endDate,
      this.expensesStatusFilter,
      this.expenseCategoryEnum,
      this.employeeEmailFilter});
}
