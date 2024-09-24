import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_expense_tracker/models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;

  final List<Expense> _expenses = [];

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

  // calculate total expenses for each month
  Future<Map<int, double>> calculateTotalExpensesByMonth() async {
    // read from data base

    await readExpenses();
    //map to keep track of all the expenses

    Map<int, double> monthlyExpenses = {};

    // iterate through each expense
    for (var expense in _expenses) {
      // extract the month from the date
      int month = expense.date.month;

      //if month not in the map initialize to 0
      if (!monthlyExpenses.containsKey(month)) {
        monthlyExpenses[month] = 0;
      }

      //add the expense to the total for the month
      monthlyExpenses[month] = monthlyExpenses[month]! + expense.amount;
    }

    return monthlyExpenses;
  }

  // get start month
  int getStartMonth() {
    if (_expenses.isEmpty) {
      return DateTime.now().month;
    }

    _expenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _expenses.first.date.month;
  }

  // current month total
  Future<double> getCurrentMonthTotal() async {
    await readExpenses();

    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    List<Expense> currentMonthlyExpenses = getExpenses.where((expense) {
      return expense.date.year == currentYear &&
          expense.date.month == currentMonth;
    }).toList();

    double total = currentMonthlyExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return total;
  }

  // get start year
  int getStartYear() {
    if (_expenses.isEmpty) {
      return DateTime.now().year;
    }

    _expenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );

    return _expenses.first.date.year;
  }
}
