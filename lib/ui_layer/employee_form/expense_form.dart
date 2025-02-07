import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data_domain/form_employee_expense/bloc_employee_form.dart';
import '../../data_domain/form_employee_expense/employee_form_helper.dart';
import '../../data_domain/main_expenses/model/expenses_model.dart';
import '../AppStyles.dart';
import '../../data_domain/utils/AppValues.dart';
import '../app_widget.dart';
import '../../data_domain/utils/base_data_controller.dart';

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
  final TextEditingController _employeeIDController = TextEditingController();
  final TextEditingController _receiptUrlController = TextEditingController();
  late EmployeeFormHelper employeeHelper;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        FocusScope.of(context).unfocus(); // Hides keyboard
      } catch (e) {}
      ExpensesModel expensesModel = ExpensesModel();
      expensesModel.title = _titleController.text;
      expensesModel.description = _descriptionController.text;
      expensesModel.amount = double.parse(_amountController.text);
      expensesModel.expensesStatus = ExpensesStatusEnum.pending;
      expensesModel.employeeID = BaseDataController().user?.uid ?? "";
      expensesModel.authorMail = BaseDataController().user?.email ?? "";
      expensesModel.category = employeeHelper.expenseCategoryEnum;
      employeeHelper.expensesModel = expensesModel;
      await employeeHelper.submitForm(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    employeeHelper = EmployeeFormHelper();
    employeeHelper.blocEmployee.employeeHelper = employeeHelper;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocProvider<BlocEmployeeForm>(
          create: (BuildContext blocContext) => employeeHelper.blocEmployee,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                        "Add Expenses",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          BlocBuilder<BlocEmployeeForm, EmployeeFormState>(
                              buildWhen: (prevState, state) {
                            if (state == EmployeeFormState.initialState ||
                                state == EmployeeFormState.photoPicked ||
                                state == EmployeeFormState.pickingImage) {
                              return true;
                            } else {
                              return false;
                            }
                          }, builder: (context, state) {
                            employeeHelper =
                                BlocProvider.of<BlocEmployeeForm>(context)
                                    .employeeHelper;
                            return Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4), // Shadow position
                                  ),
                                ],
                              ),
                              child: employeeHelper.finalPickedFile == null
                                  ? GestureDetector(
                                      onTap: () {
                                        // Handle image picking logic

                                        employeeHelper.pickImage(context);
                                      },
                                      child: const Center(
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
                                        employeeHelper.pickImage(context);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        // Match borderRadius for smooth corners
                                        child: Image.file(
                                          employeeHelper.finalPickedFile!,
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
                                  textEditingController: _titleController,
                                  validatorErrorString: "Please enter title",
                                ),
                                const Padding(padding: EdgeInsets.all(4)),
                                TextFieldWidget(
                                  hintText: "Amount",
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  textEditingController: _amountController,
                                  validatorErrorString:
                                      "Please enter a valid number",
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                      DropdownButtonFormField<ExpenseCategoryEnum>(
                        value: employeeHelper.expenseCategoryEnum,
                        decoration: InputDecoration(
                          labelText: "Select Category",
                          labelStyle: TextStyle(
                              color: AppValues.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                          prefixIcon: Icon(
                            Icons.category,
                            color: AppValues.primaryColor,
                          ),
                          suffixStyle: TextStyle(color: AppValues.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        items: ExpenseCategoryEnum.values
                            .map((ExpenseCategoryEnum category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name[0].toUpperCase() +
                                category.name
                                    .substring(1)), // Capitalize first letter
                          );
                        }).toList(),
                        onChanged: (ExpenseCategoryEnum? value) {
                          setState(() {
                            employeeHelper.expenseCategoryEnum =
                                value ?? ExpenseCategoryEnum.miscellaneous;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Please select a category" : null,
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                      TextFieldWidget(
                        hintText: "Description",
                        icon: Icons.title,
                        textInputAction: TextInputAction.newline,
                        lines: 4,
                        textEditingController: _descriptionController,
                        validatorErrorString: "Please enter a description",
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                    ],
                  ),
                ),
              ),
              // Photo section
              ElevatedButton(
                onPressed: _submitForm,
                style: AppStyles.elevatedButtonStyle(),
                child: const Text('Submit'),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _employeeIDController.dispose();
    _receiptUrlController.dispose();
    try {
      employeeHelper.finalPickedFile!.delete();
      employeeHelper.finalPickedFile = null;
    } catch (e) {}
    super.dispose();
  }
}
