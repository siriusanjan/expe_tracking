import 'package:expe_traking/main/parent/controller/expenses_helper.dart';
import 'package:expe_traking/main/parent/model/expenses_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../net/firebase_utils.dart';
import '../../../../utils/AppValues.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/base_data_controller.dart';

class ExpenseDetailView extends StatefulWidget {
  final ExpensesHelper expensesHelper;
  final ExpensesModel expense;

  const ExpenseDetailView(
      {super.key, required this.expensesHelper, required this.expense});

  @override
  State<StatefulWidget> createState() => _ExpenseDetailView();
}

class _ExpenseDetailView extends State<ExpenseDetailView> {
  late ExpensesModel expense;
  late ExpensesStatusEnum _selectedStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    expense = widget.expense;
    _selectedStatus = widget.expense.expensesStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: AppValues.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(direction: Axis.horizontal, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Expense",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Column(
                    children: [
                      Container(
                        height: 8,
                        width: 100,
                        decoration: BoxDecoration(
                          color: expense.expensesStatus ==
                                  ExpensesStatusEnum.pending
                              ? Colors.grey
                              : expense.expensesStatus ==
                                      ExpensesStatusEnum.approved
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Adds spacing between container and text
                      Text(
                        "\$${expense.amount.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center, // Centers the text
                      ),
                    ],
                  ),
                ],
              ),
              Wrap(children: [
                SingleChildScrollView(
                  // Prevents overflow issues
                  child: SizedBox(
                    // Limit height to 50% of screen
                    width: MediaQuery.of(context).size.width *
                        0.9, // Limit height to 70% of screen
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        if (expense.receiptUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              expense.receiptUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.broken_image, size: 100),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: AppUtils.capitalizeFirstLetter(
                                    expense.title),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 18)),
                            TextSpan(
                                text: " ${expense.description}",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18)),
                          ])),
                        ),
                        Text(AppUtils.formatDate(expense.timeStamp!),
                            style: TextStyle(fontSize: 10)),

                        // Status Dropdown
                        if (BaseDataController().currentUserRole ==
                            UserRole.manager)
                          Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Change Status:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              CupertinoListSection(
                                children: ExpensesStatusEnum.values
                                    .map((ExpensesStatusEnum status) {
                                  return CupertinoListTile(
                                    onTap: () {
                                      setState(() {
                                        _selectedStatus = status;
                                      });
                                      setState(() {});
                                    },
                                    title: Text(
                                      status
                                          .toString()
                                          .split('.')
                                          .last
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: status ==
                                                ExpensesStatusEnum.pending
                                            ? Colors.grey
                                            : status ==
                                                    ExpensesStatusEnum.approved
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                    leading: CupertinoRadio<ExpensesStatusEnum>(
                                      value: status,
                                      groupValue: _selectedStatus,
                                      onChanged:
                                          (ExpensesStatusEnum? newStatus) {
                                        if (newStatus != null) {
                                          setState(() {
                                            _selectedStatus = newStatus;
                                          });
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                        BaseDataController().currentUserRole == UserRole.manager
                            ? "Save"
                            : "Close",style: TextStyle(fontSize: 16),),
                  ),
                ),
              ]),
            ]),
          ),
        ));
  }
}
