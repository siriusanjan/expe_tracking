import 'package:expe_traking/main/parent/model/expenses_model.dart';

abstract class ExpenseListEvent {}

class FetchExpensesEvent extends ExpenseListEvent {}

class UpdateExpenseEvent extends ExpenseListEvent {
  final ExpensesModel expense;
  final bool shouldUpdate;
  final Function updatedIndex;

  UpdateExpenseEvent({required this.expense, this.shouldUpdate=false,required this.updatedIndex });
}