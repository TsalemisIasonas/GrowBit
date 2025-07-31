// return todays date formatted as yyyyMMdd
String todaysDateFormatted(){
  // today
  var dateTimeObject = DateTime.now();

  //year in the format yyyy
  String year = dateTimeObject.year.toString();

  //month in the format MM
  String month = dateTimeObject.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  //day in the format dd
  String day = dateTimeObject.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  // final format
  String yyyymmdd = year + month + day;
  return yyyymmdd;
}

// convert a string in the format yyyyMMdd to a DateTime object
DateTime createDateTimeObject(String yyyymmdd){
  int yyyy = int.parse(yyyymmdd.substring(0,4));
  int mm = int.parse(yyyymmdd.substring(4,6));
  int dd = int.parse(yyyymmdd.substring(6,8));
  return DateTime(yyyy, mm, dd);
}

//convert a DateTime object to a string in the format yyyyMMdd
String convertDateTimeToString(DateTime dateTimeObject){
  String year = dateTimeObject.year.toString();
  String month = dateTimeObject.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }
  String day = dateTimeObject.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }
  return year + month + day;
}