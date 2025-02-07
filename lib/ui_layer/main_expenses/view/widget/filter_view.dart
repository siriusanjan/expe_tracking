import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data_domain/main_expenses/expense_bloc.dart';
import '../../../../data_domain/main_expenses/expense_events.dart';
import '../../../../data_domain/main_expenses/model/expenses_model.dart';
import '../../../../data_domain/utils/AppStyles.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<StatefulWidget> createState() => _FilterView();
}

class _FilterView extends State<FilterView> {
  // Controllers
  TextEditingController employeeIDController = TextEditingController();
  TextEditingController employeeEmailController = TextEditingController();

  // Date Variables
  DateTime? startDate;
  DateTime? endDate;

  // Enum Variables
  ExpensesStatusEnum? selectedStatus;
  ExpenseCategoryEnum? selectedCategory;

  // Date Picker
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey.shade700,
                                size: 30,
                              ),
                            )),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Filter",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: employeeEmailController,
                      decoration: InputDecoration(
                        labelText: "Employee Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(startDate == null
                                ? "Start Date"
                                : "Start: ${startDate!.toLocal()}"
                                    .split(' ')[0]),
                            trailing: Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(endDate == null
                                ? "End Date"
                                : "End: ${endDate!.toLocal()}".split(' ')[0]),
                            trailing: Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<ExpensesStatusEnum>(
                      value: selectedStatus,
                      items: ExpensesStatusEnum.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Expense Status",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<ExpenseCategoryEnum>(
                      value: selectedCategory,
                      items: ExpenseCategoryEnum.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Expense Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print("Employee ID: ${employeeIDController.text}");
                        print(
                            "Employee Email: ${employeeEmailController.text}");
                        print("Start Date: $startDate");
                        print("End Date: $endDate");
                        print("Status: $selectedStatus");
                        print("Category: $selectedCategory");

                        BlocProvider.of<ExpenseListBloc>(context).add(
                            FilterExpensesEvent(
                                startDate: startDate,
                                endDate: endDate,
                                employeeEmailFilter:
                                    employeeEmailController.text.trim().isEmpty
                                        ? null
                                        : employeeEmailController.text.trim(),
                                expenseCategoryEnum: selectedCategory,
                                expensesStatusFilter: selectedStatus));
                        Navigator.pop(context);
                      },
                      style: AppStyles.elevatedButtonStyle(),
                      child: Text('Submit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
