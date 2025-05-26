import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/file_item.dart';

/// An dialog widget to choose the edit mode (to-do, text or markdown)
class EditModeDialog extends StatelessWidget {
  final EditMode currentMode;

  const EditModeDialog({
    super.key,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SimpleDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(locale.select_mode, style: theme.textTheme.titleMedium),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, EditMode.todo);
          },
          child:
              Row(children: [Icon(Icons.list_rounded), Text(locale.mode_todo)]),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, EditMode.text);
          },
          child: Row(children: [
            Icon(Icons.text_snippet_rounded),
            Text(locale.mode_text)
          ]),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, EditMode.markdown);
          },
          child: Row(children: [
            Icon(Icons.text_fields_rounded),
            Text(locale.mode_markdown)
          ]), // Add more options as needed
        ),
      ],
    );
  }
}
