import 'package:flutter/material.dart';
import 'package:project_expense_tracker/database/expense_database.dart';
import 'package:project_expense_tracker/pages/home_page.dart';
import 'package:project_expense_tracker/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ExpenseDatabase.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ExpenseDatabase>(
          create: (context) => ExpenseDatabase(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),

      // child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const HomePage(),
    );
  }
}
