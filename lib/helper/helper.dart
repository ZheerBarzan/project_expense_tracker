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
