import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/folder_item.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/widgets/filename_text.dart';

/// A widget that displays a folder item in the list.
class FolderItemWidget extends StatelessWidget {
  /// The file item to display.
  final FolderItem folderItem;

  /// Callback when the item is tapped.
  final VoidCallback onTap;

  /// Callback when the item is pinned.
  final VoidCallback onPin;

  /// Callback when the item is unpinned.
  final VoidCallback onUnpin;

  /// Callback when the item is deleted.
  final VoidCallback onDelete;

  /// Callback when the item is refreshed.
  final VoidCallback onRefresh;

  const FolderItemWidget(
      {super.key,
      required this.folderItem,
      required this.onTap,
      required this.onPin,
      required this.onUnpin,
      required this.onDelete,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<StateColors>()!;
    return ListTile(
      dense: true,
      title: Row(children: [
        Icon(
            folderItem.isCollapsed
                ? Icons.folder_rounded
                : Icons.folder_open_rounded,
            color: colors.dimmed),
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: FileNameText(fileName: folderItem.title)))
      ]),
      onTap: onTap,
      trailing: _buildOverflowMenu(locale, theme, colors),
      tileColor: colors.backgroundDarker,
    );
  }

  Widget _buildOverflowMenu(
      AppLocalizations locale, TextTheme theme, StateColors colors) {
    return SizedBox(
      height: 36,
      width: 28,
      child: PopupMenuButton<String>(
        padding: const EdgeInsets.all(2.0),
        icon: Icon(Icons.more_vert, color: colors.dimmed),
        itemBuilder: (BuildContext context) {
          return [
            if (folderItem.isPinned)
              PopupMenuItem<String>(
                value: 'unpin',
                child: ListTile(
                  leading: Icon(Icons.push_pin_outlined, color: colors.url),
                  title: Text(locale.unpin, style: theme.bodyMedium),
                ),
              ),
            if (!folderItem.isPinned)
              PopupMenuItem<String>(
                value: 'pin',
                child: ListTile(
                  leading: Icon(Icons.push_pin, color: colors.url),
                  title: Text(locale.pin, style: theme.bodyMedium),
                ),
              ),
            PopupMenuItem<String>(
              value: 'refresh',
              child: ListTile(
                leading: Icon(Icons.refresh_rounded,
                    color: colors.taskUnderDiscussionIcon),
                title: Text(locale.refresh, style: theme.bodyMedium),
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_rounded, color: colors.error),
                title: Text(locale.remove, style: theme.bodyMedium),
              ),
            ),
          ];
        },
        onSelected: (String value) {
          if (value == 'delete') {
            onDelete();
          } else if (value == 'pin') {
            onPin();
          } else if (value == 'unpin') {
            onUnpin();
          } else if (value == 'refresh') {
            onRefresh();
          }
        },
      ),
    );
  }
}
