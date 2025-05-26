import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/theme/theme.dart';

/// Dialog widget to enter a filename before creating the new file
class FilenameDialog extends StatelessWidget {
  final Function onConfirmed;
  final VoidCallback onCancelled;

  const FilenameDialog({
    super.key,
    required this.onConfirmed,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = TextEditingController();
    return AlertDialog(
      title: Text(locale.enter_file_name),
      content: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.none,
        autocorrect: false,
        style: AppTheme.lightThemeData.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: locale.filename_hint,
          fillColor: AppTheme.lightThemeData
              .extension<StateColors>()!
              .backgroundLighter,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: onCancelled,
          child: Text(locale.cancel),
        ),
        TextButton(
          onPressed: () => onConfirmed(controller.text),
          child: Text(locale.save,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.extension<StateColors>()?.error)),
        ),
      ],
    );
  }
}
