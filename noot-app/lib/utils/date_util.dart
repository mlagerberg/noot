import 'package:intl/intl.dart';
import 'package:todo/utils/preferences_manager.dart';

class DateUtil {

  /// Parses a date based on the To-do/Noot file format,
  /// which means it might be things like: 'mo', 'mo 9'  etc.
  /// In those cases we take an educated guess for the complete date:
  /// - Mo -> Last monday
  /// - Mo 8 -> Monday the 8th of this month or the one before
  /// - Mo 8 Apr -> Monday the 8th of April, this year
  DateTime _parse(String dateStr) {
    final now = DateTime.now();
    final weekdays = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
      'ma': 1,
      'di': 2,
      'wo': 3,
      'do': 4,
      'vr': 5,
      'za': 6,
      'zo': 7
    };

    // Check for patterns
    final datePatterns = [
      RegExp(
          r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun|ma|di|wo|do|vr|za|zo) (\d{1,2}) (\w{3,}) (\d{4})$'),
      // Full date
      RegExp(
          r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun|ma|di|wo|do|vr|za|zo) (\d{1,2}) (\w{3,})$'),
      // Day + Month
      RegExp(r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun|ma|di|wo|do|vr|za|zo) (\d{1,2})$'),
      // Day only
      RegExp(r'^(Mon|Tue|Wed|Thu|Fri|Sat|Sun|ma|di|wo|do|vr|za|zo)$'),
      // Weekday only
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(dateStr);
      if (match != null) {
        final weekday = weekdays[match.group(1)!]!;

        // Full date (weekday + day + month + year)
        if (match.groupCount == 4) {
          final day = int.parse(match.group(2)!);
          final month = DateFormat.MMM().parse(match.group(3)!).month;
          final year = int.parse(match.group(4)!);
          return DateTime(year, month, day);
        }

        // Day + month (assume current year)
        if (match.groupCount == 3) {
          final day = int.parse(match.group(2)!);
          final month = DateFormat.MMM().parse(match.group(3)!).month;
          return DateTime(now.year, month, day);
        }

        // Day only (find next occurrence of that day)
        if (match.groupCount == 2) {
          final day = int.parse(match.group(2)!);
          var result = DateTime(now.year, now.month, day);
          if (result.isAfter(now)) {
            result = DateTime(now.year, now.month + 1, day);
          }
          return result;
        }

        // Weekday only (find next occurrence)
        if (match.groupCount == 1) {
          final difference = (now.weekday + weekday) % 7;
          return now.subtract(Duration(days: difference == 0 ? 7 : difference));
        }
      }
    }
    return now;
  }

  /// Parse a date from a string.
  /// Ignores the part after the ` - `, but returns that as second part
  /// of the return tuple.
  (DateTime, String?) parseLine(String content) {
    final parts = content.split(' - ');
    String? label;
    String dateStr;
    if (parts.length == 2) {
      dateStr = parts[0];
      label = parts[1];
    } else {
      dateStr = content;
    }
    return (_parse(dateStr), label);
  }

  String formatDate(String dateFormat, DateTime date) {
    // Format the date according to the user's preferred format,
    // or fallback to the default if that fails.
    try {
      return DateFormat(dateFormat).format(date);
    } catch (e) {
      return DateFormat(PreferenceManager.defaultDateFormat).format(date);
    }
  }
}
