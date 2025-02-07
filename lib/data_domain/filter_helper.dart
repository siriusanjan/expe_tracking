import 'package:expe_traking/data_domain/utils/base_data_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main_expenses/expense_bloc.dart';
import 'main_expenses/expense_events.dart';
import 'main_expenses/model/expenses_model.dart';

enum FilterExtraEnum { startDate, endDate, email }

class FilterHelper {
  Map<dynamic, dynamic> localFilterMap = {};

  // Controllers
  TextEditingController employeeIDController = TextEditingController();
  TextEditingController employeeEmailController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  // Enum Variables
  ExpensesStatusEnum? selectedStatus;
  ExpenseCategoryEnum? selectedCategory;

  FilterHelper() {
    localFilterMap = BaseDataController().filterMap;
    setUpFilters();
  }

  void setUpFilters() {
    print("filterMapLength " + localFilterMap.length.toString());
    startDate = localFilterMap[FilterExtraEnum.startDate];
    endDate = localFilterMap[FilterExtraEnum.endDate];
    employeeEmailController.text = localFilterMap[FilterExtraEnum.email] ?? "";
    selectedCategory = localFilterMap[ExpenseCategoryEnum];
    selectedStatus = localFilterMap[ExpensesStatusEnum];
  }

  void startFilter(BuildContext context) {
    localFilterMap.clear();
    BaseDataController().filterMap = {};
    localFilterMap[FilterExtraEnum.startDate] = startDate;
    localFilterMap[FilterExtraEnum.endDate] = endDate;
    localFilterMap[FilterExtraEnum.email] =
        employeeEmailController.text.trim().isEmpty
            ? null
            : employeeEmailController.text.trim();
    localFilterMap[ExpenseCategoryEnum] = selectedCategory;
    localFilterMap[ExpensesStatusEnum] = selectedStatus;
    BaseDataController().filterMap = localFilterMap;
    BlocProvider.of<ExpenseListBloc>(context).add(FilterExpensesEvent(
        startDate: localFilterMap[FilterExtraEnum.startDate],
        endDate: localFilterMap[FilterExtraEnum.endDate],
        employeeEmailFilter: localFilterMap[FilterExtraEnum.email],
        expenseCategoryEnum: localFilterMap[ExpenseCategoryEnum],
        expensesStatusFilter: localFilterMap[ExpensesStatusEnum]));

    Navigator.pop(context);
  }

  void onReset() {
    localFilterMap = {};
    employeeEmailController.text = "";
    employeeEmailController.text = "";
    startDate = null;
    endDate = null;
    selectedStatus = null;
    selectedCategory = null;
  }
}
