import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/file_item.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/widgets/filename_text.dart';

/// A widget that displays a file item in the list.
class FileItemWidget extends StatelessWidget {
  /// The file item to display.
  final FileItem fileItem;

  /// Whether the item is selected.
  final bool isSelected;

  /// Callback when the item is tapped.
  final VoidCallback onTap;

  /// Callback when the item is pinned.
  final VoidCallback onPin;

  /// Callback when the item is unpinned.
  final VoidCallback onUnpin;

  /// Callback when the item is shared.
  final VoidCallback onShare;

  /// Callback when the item is deleted.
  final VoidCallback onDelete;

  const FileItemWidget(
      {super.key,
      required this.fileItem,
      required this.isSelected,
      required this.onTap,
      required this.onPin,
      required this.onUnpin,
      required this.onShare,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<StateColors>()!;

    return ListTile(
      dense: fileItem.isChild,
      title: Padding(
          padding: EdgeInsets.only(left: fileItem.isChild ? 32.0 : 0),
          child: FileNameText(fileName: fileItem.title)),
      subtitle: fileItem.isChild
          ? null
          : Padding(
              padding: EdgeInsets.only(left: fileItem.isChild ? 32.0 : 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fileItem.prettyDate(locale),
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      style: theme.bodySmall,
                    ),
                  ),
                  if (fileItem.isPinned)
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child:
                          Icon(Icons.push_pin, color: colors.url, size: 16.0),
                    ),
                ],
              )),
      selected: isSelected,
      // selectedColor: colors.background,
      selectedTileColor: colors.backgroundLighter,
      tileColor: colors.backgroundDarker,
      onTap: onTap,
      trailing: _buildOverflowMenu(locale, theme, colors),
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
            if (fileItem.isPinned && !fileItem.isChild)
              PopupMenuItem<String>(
                value: 'unpin',
                child: ListTile(
                  leading: Icon(Icons.push_pin_outlined, color: colors.url),
                  title: Text(locale.unpin, style: theme.bodyMedium),
                ),
              ),
            if (!fileItem.isPinned && !fileItem.isChild)
              PopupMenuItem<String>(
                value: 'pin',
                child: ListTile(
                  leading: Icon(Icons.push_pin, color: colors.url),
                  title: Text(locale.pin, style: theme.bodyMedium),
                ),
              ),
            PopupMenuItem<String>(
              value: 'share',
              child: ListTile(
                leading:
                    Icon(Icons.share, color: colors.taskUnderDiscussionIcon),
                title: Text(locale.share, style: theme.bodyMedium),
              ),
            ),
            if (!fileItem.isChild)
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: colors.error),
                  title: Text(locale.remove, style: theme.bodyMedium),
                ),
              ),
          ];
        },
        onSelected: (String value) {
          if (value == 'delete') {
            onDelete();
          } else if (value == 'share') {
            onShare();
          } else if (value == 'pin') {
            onPin();
          } else if (value == 'unpin') {
            onUnpin();
          }
        },
      ),
    );
  }
}
