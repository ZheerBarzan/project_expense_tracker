import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:project_expense_tracker/bar_graph/individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummery;
  final int startMonth;
  const MyBarGraph(
      {super.key, required this.monthlySummery, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  // initialize bar data
  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummery.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummery[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(BarChartData(
      maxY: 100,
      minY: 0,
    ));
  }
}
