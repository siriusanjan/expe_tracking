import 'package:expe_traking/data_domain/filter_helper.dart';
import 'package:expe_traking/data_domain/firebase/firebase_utils.dart';
import 'package:expe_traking/data_domain/utils/base_data_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data_domain/main_expenses/expense_bloc.dart';
import '../../../../data_domain/main_expenses/expense_events.dart';
import '../../../../data_domain/main_expenses/model/expenses_model.dart';
import '../../../AppStyles.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<StatefulWidget> createState() => _FilterView();
}

class _FilterView extends State<FilterView> {
  late FilterHelper filterHelper;

  // Date Variables

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterHelper = FilterHelper();
  }

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
          filterHelper.startDate = picked;
        } else {
          filterHelper.endDate = picked;
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text(
                              "Filter",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            child: TextButton(
                              onPressed: () {
                                filterHelper.onReset();
                                setState(() {

                                });
                              },
                              child: const Text("Reset",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (BaseDataController().currentUserRole !=
                        UserRole.employee)
                      TextFormField(
                        controller: filterHelper.employeeEmailController,
                        decoration: const InputDecoration(
                          labelText: "Employee Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(filterHelper.startDate == null
                                ? "Start Date"
                                : "${filterHelper.startDate!.toLocal().toString()}"
                                    .split(' ')[0],style: TextStyle(color: Colors.black),),
                            trailing: const Icon(Icons.calendar_today,),
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(filterHelper.endDate == null
                                ? "End Date"
                                : "${filterHelper.endDate!.toLocal()}"
                                    .split(' ')[0]),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ExpensesStatusEnum>(
                      value: filterHelper.selectedStatus,
                      items: ExpensesStatusEnum.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filterHelper.selectedStatus = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Expense Status",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ExpenseCategoryEnum>(
                      value: filterHelper.selectedCategory,
                      items: ExpenseCategoryEnum.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filterHelper.selectedCategory = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Expense Category",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        filterHelper.startFilter(context);
                      },
                      style: AppStyles.elevatedButtonStyle(),
                      child: const Text('Filter'),
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
