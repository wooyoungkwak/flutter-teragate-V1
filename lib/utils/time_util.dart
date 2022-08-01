import 'package:intl/intl.dart';

import 'package:teragate_test/utils/debug_util.dart';

String getDateToString(DateTime datetime, String formatStr) {
  DateFormat dateFormat = DateFormat(formatStr);
  return dateFormat.format(datetime);
}

DateTime getNow(){
  return DateTime.now();
}

String getDateToStringForMMDD(DateTime datetime) {
  return getDateToString(datetime, "MM-dd");
}

String getDateToStringForYYMMDD(DateTime datetime) {
  return getDateToString(datetime,"yyyy-MM-dd");
}

String getDateToStringForAll(DateTime datetime) {
  return getDateToString(datetime,"yyyy-MM-dd hh:mm:ss");
}

String getDateToStringForMMDDInNow() {
  return getDateToString(getNow(), "MM-dd");
}

String getDateToStringForYYYYMMDDInNow() {
  return getDateToString(getNow(), "yyyy-MM-dd");
}

String getDateToStringForAllInNow() {
  return getDateToStringForAll(getNow());
}

String getMinorToDate() {
  String date = getDateToString(getNow(), "MMdd");
  if ( date.substring(0, 1) == "0") {
    date = date.substring(1);
  }

  return date;
}

String getWeek() {
  return DateFormat('E', 'en_US').format(getNow());
}