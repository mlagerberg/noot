import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/theme/state_colors.dart';

/// A confirmation dialog widget to either
/// discard unsaved changes or return to the editor.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirmed;
  final VoidCallback onCancelled;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirmed,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: onCancelled,
          child: Text(locale.cancel),
        ),
        TextButton(
          onPressed: onConfirmed,
          child: Text(locale.discard,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.extension<StateColors>()?.error)),
        ),
      ],
    );
  }
}
