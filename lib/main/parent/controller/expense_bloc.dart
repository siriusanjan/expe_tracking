import 'package:expe_traking/main/parent/model/expenses_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'expense_events.dart';
import 'expenses_helper.dart';

class ExpenseListState {
  final List<ExpensesModel> expenseList;
  final bool isLoading;
  final String? error;

  ExpenseListState({
    required this.expenseList,
    this.isLoading = false,
    this.error,
  });

  ExpenseListState copyWith({
    List<ExpensesModel>? expenseList,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseListState(
      expenseList: expenseList ?? this.expenseList,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ExpenseListBloc extends Bloc<ExpenseListEvent, ExpenseListState> {
  final ExpensesHelper expensesHelper;

  ExpenseListBloc({required this.expensesHelper})
      : super(ExpenseListState(expenseList: [])) {
    // Register event handlers
    on<FetchExpensesEvent>(_onFetchExpensesEvent);
    on<UpdateExpenseEvent>(_onUpdateExpenseEvent);
  }

  Future<void> _onFetchExpensesEvent(
    FetchExpensesEvent event,
    Emitter<ExpenseListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final expenses = await expensesHelper.getExpenses();
      emit(state.copyWith(expenseList: expenses, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onUpdateExpenseEvent(
    UpdateExpenseEvent event,
    Emitter<ExpenseListState> emit,
  ) {
    int i = -1;
    int updatedIndex = -1;
    List<ExpensesModel> updatedList = event.shouldUpdate
        ? state.expenseList.map((expense) {
            i++;
            updatedIndex =
                expense.expId == event.expense.expId && updatedIndex.isNegative
                    ? i
                    : updatedIndex;
            return expense.expId == event.expense.expId
                ? event.expense
                : expense;
          }).toList()
        : [
            event.expense, // Add the new expense at the top
            ...state.expenseList,
          ];

    if (updatedIndex >= 0) {
      ExpensesModel updatedExpense = updatedList[updatedIndex];
      updatedList.removeAt(updatedIndex); // Remove from the original position
      updatedList.insert(0, updatedExpense); // Add to the top of the list
    } else if (event.shouldUpdate) {
      updatedList = [
        event.expense, // Add the new expense at the top
        ...state.expenseList,
      ];
    }
    event.updatedIndex(event.shouldUpdate ? 0 : 0,
        updatedIndex.isNegative && event.shouldUpdate ? event.shouldUpdate : !event.shouldUpdate);
    emit(state.copyWith(expenseList: updatedList));
  }
}
