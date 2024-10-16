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

  double calculateMaxValue() {
    double max = 500;

    widget.monthlySummery.sort();

    max = widget.monthlySummery.last * 1.1;

    if (max < 500) {
      max = 500;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    initializeBarData();

    double barWidth = 25;
    double spaceBetweenBars = 20;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SizedBox(
          width: barWidth * barData.length +
              spaceBetweenBars * (barData.length - 1),
          child: BarChart(
            BarChartData(
                maxY: calculateMaxValue(),
                minY: 0,
                gridData: const FlGridData(
                  show: false,
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                titlesData: const FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getBottomTitles,
                        reservedSize: 30),
                  ),
                ),
                barGroups: barData
                    .map((data) => BarChartGroupData(
                          x: data.x,
                          barRods: [
                            BarChartRodData(
                              toY: data.y,
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                              width: barWidth,
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: calculateMaxValue(),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ))
                    .toList(),
                alignment: BarChartAlignment.spaceEvenly,
                groupsSpace: spaceBetweenBars),
          ),
        ),
      ),
    );
  }

  // bottom titles
}

Widget getBottomTitles(double value, TitleMeta meta) {
  var textStyle = TextStyle(
    color: Colors.grey.shade700,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );
  String text;

  switch (value.toInt() % 12) {
    case 0:
      text = 'JAN';
      break;
    case 1:
      text = 'FEB';
      break;
    case 2:
      text = 'MAR';
      break;
    case 3:
      text = 'APR';
      break;
    case 4:
      text = 'MAY';
      break;
    case 5:
      text = 'JUN';
      break;
    case 6:
      text = 'JUL';
      break;
    case 7:
      text = 'AUG';
      break;
    case 8:
      text = 'SEP';
      break;
    case 9:
      text = 'OCT';
      break;
    case 10:
      text = 'NOV';
      break;
    case 11:
      text = 'DEC ';
      break;
    default:
      text = '';
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(text, style: textStyle),
  );
}
