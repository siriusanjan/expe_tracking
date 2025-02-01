import 'package:expe_traking/main/employee/controller/bloc_employee.dart';
import 'package:expe_traking/main/employee/controller/employee_helper.dart';
import 'package:expe_traking/utils/AppStyles.dart';
import 'package:expe_traking/utils/AppValues.dart';
import 'package:expe_traking/utils/app_widget.dart';
import 'package:expe_traking/utils/permission_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key});

  @override
  _ExpenseFormState createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _receiptUrlController = TextEditingController();
  late EmployeeHelper employeeHelper;

  String _status = "pending";

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("expenses").add({
          "title": _titleController.text,
          "description": _descriptionController.text,
          "amount": double.parse(_amountController.text),
          "userId": _userIdController.text,
          "receiptUrl": _receiptUrlController.text,
          "status": _status,
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Expense submitted successfully!')),
        );

        // Clear the form after submission
        _titleController.clear();
        _descriptionController.clear();
        _amountController.clear();
        _userIdController.clear();
        _receiptUrlController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting expense: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        // Ensures the keyboard doesn't overlap the UI
        body: SingleChildScrollView(
          child: SizedBox(
            height: AppValues.mainScreenHeight * 0.75,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.shade700,
                        size: 30,
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Add Expenses",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Container(
                      width: 30,
                    )
                  ],
                ),
                Expanded(
                  child:Align(
                    alignment: Alignment.center,
                    child: Form(
                    key: _formKey,
                    child: Expanded(
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                BlocBuilder<BlocEmployee, EmployeeState>(
                                    buildWhen: (prevState, state) {
                                  if (state == EmployeeState.initialState ||
                                      state == EmployeeState.photoPicked ||
                                      state == EmployeeState.pickingImage) {
                                    return true;
                                  } else {
                                    return false;
                                  }
                                }, builder: (context, state) {
                                  employeeHelper =
                                      BlocProvider.of<BlocEmployee>(context)
                                          .employeeHelper;
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(
                                              0, 4), // Shadow position
                                        ),
                                      ],
                                    ),
                                    child: employeeHelper.finalPickedFile ==
                                            null
                                        ? GestureDetector(
                                            onTap: () {
                                              // Handle image picking logic

                                              employeeHelper
                                                  .pickImage(context);
                                            },
                                            child: Center(
                                              child: Icon(
                                                Icons.camera_alt,
                                                color: Colors.black45,
                                                size:
                                                    36, // Larger icon for better visual impact
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              // Handle image picking logic
                                              employeeHelper
                                                  .pickImage(context);
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              // Match borderRadius for smooth corners
                                              child: Image.file(
                                                employeeHelper
                                                    .finalPickedFile!,
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                  );
                                }),
                                Expanded(
                                  child: Column(
                                    children: [
                                      TextFieldWidget(
                                        hintText: "Enter title",
                                        icon: Icons.title,
                                        textEditingController:
                                            _titleController,
                                        validatorErrorString:
                                            "Please enter title",
                                      ),
                                      Padding(padding: EdgeInsets.all(4)),
                                      TextFieldWidget(
                                        hintText: "Amount",
                                        icon: Icons.attach_money,
                                        keyboardType: TextInputType.number,
                                        textEditingController:
                                            _amountController,
                                        validatorErrorString:
                                            "Please enter a valid number",
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(padding: EdgeInsets.all(4)),
                            TextFieldWidget(
                              hintText: "Description",
                              icon: Icons.title,
                              textInputAction: TextInputAction.newline,

                              lines: 4,
                              textEditingController: _descriptionController,
                              validatorErrorString:
                                  "Please enter a description",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Photo section
                ElevatedButton(
                  onPressed: _submitForm,
                  style: AppStyles.elevatedButtonStyle(),
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _userIdController.dispose();
    _receiptUrlController.dispose();
    try {
      employeeHelper.finalPickedFile!.delete();
      employeeHelper.finalPickedFile = null;
    } catch (e) {}
    super.dispose();
  }
}
