import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_expense_tracker/models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;

  List<Expense> expenses = [];

  // setup

  //initalize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  // getters

  // operations

  // helpers
}
