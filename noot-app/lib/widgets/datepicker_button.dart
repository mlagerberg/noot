import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/utils/date_util.dart';
import 'package:todo/utils/preferences_manager.dart';

import '../theme/state_colors.dart';

/// Small icon button that opens a date picker dialog when pressed.
/// Takes a content string that can be more than just a date; since it is
/// compatible with the To-do format and can contain a label like
/// `{date} - additional label`. This label is preserved when the user uses the
/// date picker to change the date.
class DatePickerButton extends StatelessWidget {
  DatePickerButton({
    super.key,
    required this.content,
    required this.onDatePicked,
  });
  final String content;
  final Function(String, String?) onDatePicked;
  final dateUtil = DateUtil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      child: Icon(
        Icons.today_rounded,
        color: theme.extension<StateColors>()?.date,
      ),
      onTap: () async {
        final (date, label) = dateUtil.parseLine(content);
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(1900),
          lastDate: DateTime(2200),
        );
        if (pickedDate != null) {
          // Find the right format
          final prefs = await SharedPreferences.getInstance();
          final prefsMan = PreferenceManager(prefs);

          // Handle the picked date
          onDatePicked(dateUtil.formatDate(prefsMan.dateFormat, pickedDate), label);
        }
      },
    );
  }
}
