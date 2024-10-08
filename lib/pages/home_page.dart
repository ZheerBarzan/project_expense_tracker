import 'package:flutter/material.dart';
import 'package:project_expense_tracker/bar_graph/bar_graph.dart';
import 'package:project_expense_tracker/components/my_drawer.dart';
import 'package:project_expense_tracker/components/my_list_tile.dart';
import 'package:project_expense_tracker/database/expense_database.dart';
import 'package:project_expense_tracker/helper/helper.dart';
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

  Future<Map<String, double>>? _monthlyTotalFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    refreshGraphData();
    super.initState();
  }

  void refreshGraphData() {
    _monthlyTotalFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateTotalExpensesByMonth();

    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .getCurrentMonthTotal();
  }

  // open new expense box
  void _openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
        actions: [_cancelButton(), _addButton()],
      ),
    );
  }

  // edit expense
  void _editExpense(Expense expense) async {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: existingName,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: existingAmount,
              ),
            ),
          ],
        ),
        actions: [_cancelButton(), _editButton(expense)],
      ),
    );
  }

  // delete expense
  void _deleteExpense(Expense expense) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Text("The expense ${expense.name} will be deleted."),
        actions: [_cancelButton(), _deleteButton(expense)],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        int monthCount = calculateMonthCount(
            startYear, startMonth, currentYear, currentMonth);

        // to be deleted maybe
        List<Expense> currentMonthlyExpenses =
            value.getExpenses.where((expense) {
          return expense.date.year == currentYear &&
              expense.date.month == currentMonth;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Expense Tracker"),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
          ),
          drawer: const MyDrawer(),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onPressed: _openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(children: [
              FutureBuilder<double>(
                  future: _calculateCurrentMonthTotal,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(getCurrentMonthName()),
                          Text(
                              " Total: \$${snapshot.data!.toStringAsFixed(2)}"),
                        ],
                      );
                    } else {
                      return const Text("Total: loading...");
                    }
                  }),
              const SizedBox(height: 20),
              // graph ui
              SizedBox(
                height: 250,
                child: FutureBuilder(
                  future: _monthlyTotalFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, double> monthlyTotals = snapshot.data ?? {};

                      List<double> monthlySummery =
                          List.generate(monthCount, (index) {
                        int year = startYear + (startMonth + index - 1) ~/ 12;
                        int month = (startMonth + index - 1) % 12 + 1;

                        String yearMonthKey = "$year-$month";

                        return monthlyTotals[yearMonthKey] ?? 0.0;
                      });

                      return MyBarGraph(
                          monthlySummery: monthlySummery,
                          startMonth: startMonth + 1);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),

              // expense ui
              Expanded(
                child: ListView.builder(
                    itemCount: value.getExpenses.length,
                    //itemCount: currentMonthlyExpenses.length,
                    itemBuilder: (context, index) {
                      //int reversedIndex = currentMonthlyExpenses.length - 1 - index;
                      int reversedIndex = value.getExpenses.length - 1 - index;
                      Expense individualExpense =
                          //currentMonthlyExpenses[reversedIndex];
                          value.getExpenses[reversedIndex];

                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) =>
                            _editExpense(individualExpense),
                        onDeletePressed: (context) =>
                            _deleteExpense(individualExpense),
                      );
                    }),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      child: const Text("cancel"),
      onPressed: () {
        Navigator.of(context).pop();
        _nameController.clear();
        _amountController.clear();
      },
    );
  }

  Widget _addButton() {
    return MaterialButton(
      child: const Text("Add"),
      onPressed: () async {
        // add to database
        if (_nameController.text.isNotEmpty &&
            _amountController.text.isNotEmpty) {
          Navigator.of(context).pop();

          Expense expense = Expense(
            name: _nameController.text,
            amount: convertStringToDouble(_amountController.text),
            date: DateTime.now(),
          );
          await context.read<ExpenseDatabase>().createExpense(expense);

          refreshGraphData();

          _nameController.clear();
          _amountController.clear();
        }
      },
    );
  }

  Widget _editButton(Expense expense) {
    return MaterialButton(
      child: const Text("Save"),
      onPressed: () async {
        // add to database
        if (_nameController.text.isNotEmpty ||
            _amountController.text.isNotEmpty) {
          Navigator.of(context).pop();

          Expense updatedExpense = Expense(
            name: _nameController.text.isNotEmpty
                ? _nameController.text
                : expense.name,
            amount: _amountController.text.isNotEmpty
                ? convertStringToDouble(_amountController.text)
                : convertStringToDouble(expense.amount.toString()),
            date: expense.date,
          );

          int id = expense.id;

          await context
              .read<ExpenseDatabase>()
              .updateExpense(id, updatedExpense);
          refreshGraphData();

          _nameController.clear();
          _amountController.clear();
        }
      },
    );
  }

  Widget _deleteButton(Expense expense) {
    return MaterialButton(
      child: const Text("Delete"),
      onPressed: () async {
        // add to database

        Navigator.of(context).pop();

        int id = expense.id;

        await context.read<ExpenseDatabase>().deleteExpense(id);
        refreshGraphData();
      },
    );
  }
}
