import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/theme/theme.dart';

/// A dialog that shows when the file has been changed externally,
/// asking the user if they want to keep editing or want to reload the file
/// with the external changes.
class FileChangedDialog extends StatelessWidget {
  final bool isDeleted;
  final VoidCallback onReload;
  final VoidCallback onKeepEditing;

  const FileChangedDialog({
    super.key,
    required this.isDeleted,
    required this.onReload,
    required this.onKeepEditing,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(locale.file_changed),
      content: Text(isDeleted ? locale.file_deleted : locale.file_modified),
      actions: [
        TextButton(
          onPressed: onKeepEditing,
          child: Text(locale.keep_editing),
        ),
        TextButton(
          onPressed: onReload,
          child: Text(isDeleted ? locale.discard_changes : locale.reload,
              style: AppTheme.entryTextStyle.copyWith(color: AppTheme.red)),
        ),
      ],
    );
  }
}
