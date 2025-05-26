import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/models.dart';
import 'package:todo/theme/state_colors.dart';

/// Utility class for Entry related functions.
class EntryUtils {
  /// Gets the display name for an [EntryType].
  static String getTypeName(AppLocalizations locale, EntryType type) {
    switch (type) {
      case EntryType.task:
        return locale.type_task;
      case EntryType.subtask:
        return locale.type_subtask;
      case EntryType.date:
        return locale.type_date;
      case EntryType.title:
        return locale.type_title;
      case EntryType.separator:
        return locale.type_separator;
      case EntryType.empty:
        return locale.type_empty;
      default:
        return locale.type_text;
    }
  }

  /// Builds the icon for an [EntryType].
  static Widget buildEntryTypeIcon(ThemeData theme, EntryType type) {
    IconData iconData;
    Color color;
    StateColors stateColors = theme.extension<StateColors>()!;

    color = stateColors.entryColor(type);
    switch (type) {
      case EntryType.task:
        iconData = Icons.check_circle_rounded;
        break;
      case EntryType.subtask:
        iconData = Icons.subdirectory_arrow_right_rounded;
        break;
      case EntryType.date:
        iconData = Icons.today_rounded;
        break;
      case EntryType.separator:
        iconData = Icons.linear_scale;
        break;
      case EntryType.title:
        iconData = Icons.tag_rounded;
        break;
      case EntryType.text:
        iconData = Icons.text_fields_rounded;
        color = stateColors.text;
        break;
      case EntryType.empty:
        iconData = Icons.space_bar_rounded;
        break;
    }

    return Row(children: [
      SizedBox(width: 20, height: 30, child: Icon(iconData, color: color)),
      const SizedBox(width: 16),
    ]);
  }
}
