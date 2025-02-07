import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/database_helper.dart';
import '../utils/AppValues.dart';
import 'expense_events.dart';
import 'expenses_helper.dart';
import 'model/expenses_model.dart';

class ExpenseListState {
  final List<ExpensesModel> expenseList;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMoreData;
  final int pageSize;
  final Map<ExpenseCategoryEnum, double> expenseCategoryTotal;

  ExpenseListState(
      {required this.expenseList,
      this.isLoading = false,
      this.error,
      this.currentPage = 0,
      this.hasMoreData = true,
      required this.expenseCategoryTotal,
      this.pageSize = AppValues.paginationLimit});

  ExpenseListState copyWith(
      {List<ExpensesModel>? expenseList,
      bool? isLoading,
      String? error,
      int? currentPage,
      bool? hasMoreData,
      Map<ExpenseCategoryEnum, double>? expenseCategoryTotal,
      int? pageSize}) {
    return ExpenseListState(
        expenseList: expenseList ?? this.expenseList,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        currentPage: currentPage ?? this.currentPage,
        hasMoreData: hasMoreData ?? this.hasMoreData,
        expenseCategoryTotal: expenseCategoryTotal ?? {},
        pageSize: pageSize ?? this.pageSize);
  }
}

class ExpenseListBloc extends Bloc<ExpenseListEvent, ExpenseListState> {
  final ExpensesHelper expensesHelper;

  ExpenseListBloc({required this.expensesHelper})
      : super(ExpenseListState(expenseList: [], expenseCategoryTotal: {})) {
    // Register event handlers
    on<FetchExpensesEvent>(_onFetchExpensesEvent);
    on<UpdateExpenseEvent>(_onUpdateExpenseEvent);
    on<FilterExpensesEvent>(_onFilterExpensesEvent);
    on<LoadMoreExpensesEvent>(_onLoadMoreExpensesEvent);
  }

  Future<void> _onLoadMoreExpensesEvent(
    LoadMoreExpensesEvent event,
    Emitter<ExpenseListState> emit,
  ) async {
    if (!state.hasMoreData || state.isLoading) return; // Stop if no more data

    emit(state.copyWith(isLoading: true,expenseCategoryTotal: state.expenseCategoryTotal));

    try {
      List<ExpensesModel> moreExpenses =
          await DatabaseHelper.instance.getFilteredExpenses(
        page: state.currentPage,
      );
      final addedExpenses = [...state.expenseList, ...moreExpenses];
      emit(state.copyWith(
        expenseCategoryTotal: state.expenseCategoryTotal,
        expenseList: addedExpenses,
        // Append new data
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMoreData: moreExpenses.length ==
            AppValues.paginationLimit, // Check if more data exists
      ));
    } catch (e) {
      emit(state.copyWith(
          error: e.toString(),
          isLoading: false,
          expenseCategoryTotal: state.expenseCategoryTotal));
    }
  }

  Future<void> _onFilterExpensesEvent(
      FilterExpensesEvent event, Emitter<ExpenseListState> emit) async {
    emit(state.copyWith(isLoading: true,expenseCategoryTotal: state.expenseCategoryTotal));
    try {
      final mapCategoryTotal = await expensesHelper.getExpenseCategoryWiseTotal(
        startDate: event.startDate,
        endDate: event.endDate,
        expensesStatusFilter: event.expensesStatusFilter,
        expenseCategoryEnum: event.expenseCategoryEnum,
        employeeEmailFilter: event.employeeEmailFilter,
      );
      final List<ExpensesModel> expenses = await expensesHelper.filterExpenses(
          startDate: event.startDate,
          endDate: event.endDate,
          expensesStatusFilter: event.expensesStatusFilter,
          expenseCategoryEnum: event.expenseCategoryEnum,
          employeeEmailFilter: event.employeeEmailFilter,
          expensesList: state.expenseList);
      emit(state.copyWith(
        expenseCategoryTotal: mapCategoryTotal,
        expenseList: expenses,
        isLoading: false,
        currentPage: 1,
        hasMoreData: expenses.length == state.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
          error: e.toString(),
          isLoading: false,
          expenseCategoryTotal: state.expenseCategoryTotal));
    }
  }

  Future<void> _onFetchExpensesEvent(
    FetchExpensesEvent event,
    Emitter<ExpenseListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, currentPage: 0,expenseCategoryTotal: state.expenseCategoryTotal));

    try {
      final expensesServer = await expensesHelper.getExpenses();
      await DatabaseHelper.instance.clearExpenses();
      await DatabaseHelper.instance.insertExpensesList(expensesServer);
      final mapCategoryTotal =
          await expensesHelper.getExpenseCategoryWiseTotal();
      print("fetchCatTotal "+mapCategoryTotal.length.toString());
      List<ExpensesModel> expensesList =
          await DatabaseHelper.instance.getFilteredExpenses(page: 0);
      print("fetchItemTotal "+expensesList.length.toString().toString());

      emit(state.copyWith(
        expenseCategoryTotal: mapCategoryTotal,
        expenseList: expensesList,
        isLoading: false,
        currentPage: 1,
        hasMoreData: expensesList.length == state.pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
          error: e.toString(),
          isLoading: false,
          expenseCategoryTotal: state.expenseCategoryTotal));
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
    event.updatedIndex(
        event.shouldUpdate ? 0 : 0,
        updatedIndex.isNegative && event.shouldUpdate
            ? event.shouldUpdate
            : !event.shouldUpdate);
    emit(state.copyWith(expenseList: updatedList,expenseCategoryTotal: state.expenseCategoryTotal));
  }
}
