import 'package:flutter/material.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/utils/preferences_manager.dart';

import '../theme/theme.dart';

/// Line in the settings screen that contains a text field for the user to edit.
/// No validation on the input is done.
class TextSetting extends StatelessWidget {
  const TextSetting(
      {super.key,
      required this.title,
      this.enabled = true,
      this.description,
      required this.value,
      required this.onSettingChanged});

  final String title;
  final bool enabled;
  final String? description;
  final String value;
  final ValueChanged<String>? onSettingChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final colors = AppTheme.lightThemeData.extension<StateColors>()!;

    return ListTile(
      title: Text(
        title,
        style: theme.bodyMedium,
      ),
      subtitle: description != null
          ? Text(description!, style: theme.bodySmall)
          : null,
      trailing: SizedBox(
          width: 150,
          height: 48,
          child: TextField(
              controller: TextEditingController()..text = value,
              enabled: enabled,
              autocorrect: false,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  borderSide: BorderSide(width: 2.0, color: colors.dimmed),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  borderSide: BorderSide(width: 2.0, color: colors.date),
                ),
                fillColor: colors.backgroundLighter,
                hintText: PreferenceManager.defaultDateFormat,
              ),
              style: AppTheme.lightThemeData.textTheme.bodyMedium,
              maxLines: 1,
              onChanged: (value) => {
                    if (enabled) {onSettingChanged!(value)}
                  })),
    );
  }
}
