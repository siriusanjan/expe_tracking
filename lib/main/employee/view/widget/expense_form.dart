import 'package:expe_traking/utils/AppStyles.dart';
import 'package:expe_traking/utils/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    return Column(
      mainAxisSize: MainAxisSize.min,
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
            child: Container(
          child: Center(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFieldWidget(
                      hintText: "Enter title",
                      icon: Icons.title,
                      textEditingController: _titleController,
                      validatorErrorString: "Please enter title",
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    TextFieldWidget(
                      hintText: "Description",
                      icon: Icons.title,
                      textEditingController: _descriptionController,
                      validatorErrorString: "Please enter a description",
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    TextFieldWidget(
                      hintText: "Amount",
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      textEditingController: _amountController,
                      validatorErrorString: "Please enter a valid number",
                    ),
                  ],
                ),
              ),
            ),
          ),
        )),
        ElevatedButton(
          onPressed: _submitForm,
          style: AppStyles.elevatedButtonStyle(),
          child: Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _userIdController.dispose();
    _receiptUrlController.dispose();
    super.dispose();
  }
}
