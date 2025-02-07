import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../data_domain/firebase/firebase_utils.dart';
import '../../../../data_domain/main_expenses/expenses_helper.dart';
import '../../../../data_domain/main_expenses/model/expenses_model.dart';
import '../../../../data_domain/utils/AppDialogue.dart';
import '../../../../data_domain/utils/AppValues.dart';
import '../../../../data_domain/utils/app_utils.dart';
import '../../../../data_domain/utils/base_data_controller.dart';

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
                  const Text(
                    "Expense",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Column(
                    children: [
                      Container(
                        height: 8,
                        width: 70,
                        decoration: BoxDecoration(
                          color: _selectedStatus == ExpensesStatusEnum.pending
                              ? Colors.grey
                              : _selectedStatus == ExpensesStatusEnum.approved
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Adds spacing between container and text
                      Text(
                        "\$${AppUtils.formatDollor(expense.amount)}",
                        style: const TextStyle(fontSize: 18),
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
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.account_circle, size: 24),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "${BaseDataController().user?.email!.split('@')[0].toUpperCase()}",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            )
                          ],
                        ),
                        const SizedBox(
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
                                  const Icon(Icons.broken_image, size: 100),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: AppUtils.capitalizeFirstLetter(
                                    expense.title),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    fontSize: 18)),
                            TextSpan(
                                text: " ${expense.description}",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 18)),
                          ])),
                        ),
                        Row(children: [
                          Text(AppUtils.formatDate(expense.timeStamp!),
                              style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 10),
                          Container(
                            height: 8,
                            width: 20,
                            decoration: BoxDecoration(
                              color:
                                  _selectedStatus == ExpensesStatusEnum.pending
                                      ? Colors.grey
                                      : _selectedStatus ==
                                              ExpensesStatusEnum.approved
                                          ? Colors.green
                                          : Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "${AppUtils.capitalizeFirstLetter(_selectedStatus.name)} ${(AppUtils.capitalizeFirstLetter(_selectedStatus != ExpensesStatusEnum.pending ? "by ${expense.updaterMail == BaseDataController().user?.email && _selectedStatus != expense.expensesStatus ? "You" : expense.updaterMail}" : ""))} ",
                            style: TextStyle(color: Colors.grey, fontSize: 10),
                          )
                        ]),

                        // Status Dropdown
                        if (BaseDataController().currentUserRole ==
                            UserRole.manager)
                          Wrap(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: Text(
                                  'Change Status:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
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
                BaseDataController().currentUserRole == UserRole.manager
                    ? Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Cancel",
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_selectedStatus != expense.expensesStatus) {
                                  AppDialogue.showLoadingDialog(context);
                                  expense.updaterMail =
                                      BaseDataController().user?.email ?? "";
                                  expense.expensesStatus = _selectedStatus;
                                  BaseDataController()
                                      .updateExpenseStatus(expense)
                                      .then((_) {
                                    BaseDataController().updateExpenseList(
                                        expense,
                                        shouldUpdate: true);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  });
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Close",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
              ]),
            ]),
          ),
        ));
  }
}
