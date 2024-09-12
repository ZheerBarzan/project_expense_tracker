import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_expense_tracker/models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;

  List<Expense> _expenses = [];

  // setup

  //initalize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // getters
  List<Expense> get getExpenses => _expenses;

  // operations

  //create
  Future<void> createExpense(Expense expense) async {
    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
    });

    await readExpenses();
  }

  //read
  Future<void> readExpenses() async {
    List<Expense> expenses = await isar.expenses.where().findAll();

    _expenses.clear();
    _expenses.addAll(expenses);

    notifyListeners();
  }

  //update

  Future<void> updateExpense(int id, Expense expense) async {
    expense.id = id;

    await isar.writeTxn(() async {
      await isar.expenses.put(expense);
    });

    await readExpenses();
  }

  //delete
  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpenses();
  }

  // helpers
}
