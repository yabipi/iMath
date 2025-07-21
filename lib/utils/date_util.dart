
import 'package:intl/intl.dart';

class DateUtil {

  static String formatDate(DateTime dateTime, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(dateTime);
  }
}