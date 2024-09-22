import 'package:intl/intl.dart';

String formatDate(DateTime timestamp) {
  DateTime dateTime = timestamp.toLocal();

  String year = dateTime.year.toString();
  String month = dateTime.month.toString();
  String day = dateTime.day.toString();

  String formattedDate = "$year-$month-$day";

  return formattedDate;
}

double convertStringToDouble(String value) {
  double? result = double.tryParse(value);
  return result ?? 0.0;
}

String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  return format.format(amount);
}

int calculateMonthCount(
    int startYear, int startMonth, int currentYear, int currentMonth) {
  int monthCount = (currentYear - startYear) * 12 + (currentMonth - startMonth);

  return monthCount;
}
