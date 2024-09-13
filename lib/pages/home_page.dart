import 'package:flutter/material.dart';
import 'package:project_expense_tracker/database/expense_database.dart';
import 'package:project_expense_tracker/models/expense.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // open new expense box
  void _openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("New Expense"),
        content: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Name",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                hintText: "Amount",
              ),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            child: const Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop();
              _nameController.clear();
              _amountController.clear();
            },
          ),
          MaterialButton(
            child: const Text("Add"),
            onPressed: () {
              // add to database
              if (_nameController.text.isNotEmpty &&
                  _amountController.text.isNotEmpty) {
                Navigator.of(context).pop();

                Expense expnese = Expense(
                  name: _nameController.text,
                  amount: double.parse(_amountController.text),
                  date: DateTime.now(),
                );
                Provider.of<ExpenseDatabase>(context, listen: false);

                _nameController.clear();
                _amountController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewExpenseBox,
        child: const Icon(Icons.add),
      ),
    );
  }
}
