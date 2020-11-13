
import 'package:intl/intl.dart';

class Utils {
  static DateTime getDateFromMilis(int milliseconds) {
    return new DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  static String getDateStringFromMilis(int milliseconds) {
    final date = getDateFromMilis(milliseconds);
    final format = DateFormat.yMMMMd().add_jms();
    return format.format(date);
  }
}