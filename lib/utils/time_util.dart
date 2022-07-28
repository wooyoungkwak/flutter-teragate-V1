import 'package:intl/intl.dart';

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