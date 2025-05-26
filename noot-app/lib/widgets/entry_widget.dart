import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/models.dart';
import 'package:todo/repository/parser.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/theme/theme.dart';

import 'datepicker_button.dart';

/// A single row in the To-do mode editor. Represents a single line in the
/// edited file, which can be a task, subtask, date, title, separator, etc.
/// Controls editing the entry, and shows an overflow menu for more options,
/// the actions of which are passed on to the parent and are not handled in this
/// widget.
class EntryWidget extends StatelessWidget {
  final int index;
  final Entry entry;
  final void Function(TaskState)? onTapIcon;
  final VoidCallback? onTapText;
  final void Function(Entry, String)? onEntryUpdated;
  final VoidCallback onDelete;
  final VoidCallback onInsertBelow;
  final VoidCallback onInsertChild;
  final VoidCallback? onInsertAbove;
  final VoidCallback? onInsertDateAbove;
  final VoidCallback? onCut;
  final VoidCallback? onCopy;
  final VoidCallback? onPasteAbove;
  final VoidCallback? onPasteBelow;
  final bool canPaste;
  final bool useTabletLayout;

  const EntryWidget({
    super.key,
    required this.index,
    required this.entry,
    this.onTapIcon,
    this.onTapText,
    this.onEntryUpdated,
    required this.onDelete,
    required this.onInsertBelow,
    required this.onInsertChild,
    this.onInsertAbove,
    this.onInsertDateAbove,
    this.onCut,
    this.onCopy,
    this.onPasteAbove,
    this.onPasteBelow,
    this.canPaste = false,
    this.useTabletLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          // Because lines are very long on a tablet, we move the overflow menu
          // to the left so it is easier to track the lines.
          textDirection:
              useTabletLayout ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(child: _buildEntryContent(context, locale, theme)),
            _buildOverflowMenu(locale, theme, index),
          ],
        ));
  }

  /// Builds the content of the entry for each of the entry types.
  Widget _buildEntryContent(
      BuildContext context, AppLocalizations locale, ThemeData theme) {
    switch (entry.type) {
      case EntryType.task:
        return _buildTaskContent(context, locale, theme);
      case EntryType.subtask:
        return _buildSubtaskContent(context, locale, theme);
      case EntryType.date:
        return _buildDateContent(theme);
      case EntryType.title:
        return _buildTitleContent(theme);
      case EntryType.separator:
        return _buildSeparatorContent(theme);
      default:
        return _buildTextContent(theme);
    }
  }

  Widget _buildOverflowMenu(
      AppLocalizations locale, ThemeData theme, int index) {
    final colors = theme.extension<StateColors>()!;
    return SizedBox(
        height: 36,
        width: useTabletLayout ? 36 : 28,
        child: PopupMenuButton<String>(
          padding: useTabletLayout
              ? const EdgeInsets.only(top: 2, bottom: 2, left: 0, right: 8)
              : const EdgeInsets.all(2.0),
          icon: Icon(Icons.more_vert, color: theme.hintColor),
          onSelected: (String value) {
            if (value == locale.delete) {
              onDelete();
            } else if (value == locale.insert_below) {
              onInsertBelow();
            } else if (value == locale.insert_subtask) {
              onInsertChild();
            } else if (value == locale.insert_above) {
              onInsertAbove?.call();
            } else if (value == locale.insert_next_day) {
              onInsertDateAbove?.call();
            } else if (value == locale.cut) {
              onCut?.call();
            } else if (value == locale.copy) {
              onCopy?.call();
            } else if (value == locale.paste_above) {
              onPasteAbove?.call();
            } else if (value == locale.paste_below) {
              onPasteBelow?.call();
            }
          },
          itemBuilder: (BuildContext context) {
            var menuItems = <PopupMenuEntry<String>>[];

            // Clipboard operations - always at the top
            menuItems.add(
              PopupMenuItem<String>(
                value: locale.cut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.cut_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(locale.cut,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );

            menuItems.add(
              PopupMenuItem<String>(
                value: locale.copy,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.copy_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(locale.copy,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );

            // Paste operations - only enabled if there's something to paste
            if (canPaste) {
              if (index == 0) {
                menuItems.add(
                  PopupMenuItem<String>(
                    value: locale.paste_above,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(locale.paste_above,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }

              menuItems.add(
                PopupMenuItem<String>(
                  value: locale.paste_below,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_downward_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(locale.paste_below,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }

            // Separator between clipboard and other operations
            menuItems.add(const PopupMenuDivider());

            // Standard operations
            if (entry.type == EntryType.date) {
              menuItems.add(
                PopupMenuItem<String>(
                  value: locale.insert_next_day,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.today_rounded, size: 20, color: colors.date),
                      const SizedBox(width: 8),
                      Text(locale.insert_next_day,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }

            // The 'insert above' operation is only available for the first
            // entry to keep the overflow menu short.
            if (index == 0) {
              menuItems.add(
                PopupMenuItem<String>(
                  value: locale.insert_above,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_circle_up_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(locale.insert_above,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }

            menuItems.add(
              PopupMenuItem<String>(
                value: locale.insert_below,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_circle_down_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(locale.insert_below,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );

            if (entry.type == EntryType.task) {
              menuItems.add(
                PopupMenuItem<String>(
                  value: locale.insert_subtask,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.subdirectory_arrow_right_rounded,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(locale.insert_subtask,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }

            menuItems.add(
              PopupMenuItem<String>(
                value: locale.delete,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20, color: colors.error),
                    const SizedBox(width: 8),
                    Text(locale.delete,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );

            return menuItems;
          },
        ));
  }

  Color _getTaskTextColor(ThemeData theme) {
    return theme.extension<StateColors>()?.taskStateColorText(
            entry.displayState ?? entry.state ?? TaskState.open) ??
        Colors.grey;
  }

  Widget _buildTaskStateIcon(ThemeData theme) {
    IconData iconData;
    Color color = theme
        .extension<StateColors>()!
        .taskStateColor(entry.state ?? TaskState.open);
    iconData = AppTheme.taskStateIcons[entry.state ?? TaskState.open]!;

    return Row(children: [
      SizedBox(width: 20, height: 30, child: Icon(iconData, color: color)),
      const SizedBox(width: 16),
    ]);
  }

  /// Content widget specifically for tasks
  Widget _buildTaskContent(
      BuildContext context, AppLocalizations locale, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTapDown: (TapDownDetails details) => _showTaskStateMenu(
              context, locale, theme, details.globalPosition),
          child: _buildTaskStateIcon(theme),
        ),
        Expanded(
            child: GestureDetector(
                onTap: onTapText,
                child: Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    // Adjust padding to align with text baseline
                    child: Parser.highlightText(
                        theme, entry, _getTaskTextColor(theme))))),
      ],
    );
  }

  String _getStateName(AppLocalizations locale, TaskState state) {
    switch (state) {
      case TaskState.open:
        return locale.state_open;
      case TaskState.done:
        return locale.state_done;
      case TaskState.rejected:
        return locale.state_rejected;
      case TaskState.important:
        return locale.state_important;
      case TaskState.underDiscussion:
        return locale.state_under_discussion;
      case TaskState.inProgress:
        return locale.state_in_progress;
    }
  }

  /// Popup menu to change the state of a task
  void _showTaskStateMenu(BuildContext context, AppLocalizations locale,
      ThemeData theme, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: TaskState.values.map((TaskState state) {
        return PopupMenuItem<TaskState>(
          value: state,
          child: Row(
            children: [
              Icon(AppTheme.taskStateIcons[state],
                  color: theme.extension<StateColors>()!.taskStateColor(state)),
              const SizedBox(width: 8),
              Text(_getStateName(locale, state),
                  style: theme.textTheme.bodyMedium),
            ],
          ),
        );
      }).toList(),
    ).then((TaskState? selectedState) {
      if (selectedState != null) {
        onTapIcon?.call(selectedState);
      }
    });
  }

  /// Specific content for subtasks. Same as tasks, but indented.
  Widget _buildSubtaskContent(
      BuildContext context, AppLocalizations locale, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: _buildTaskContent(context, locale, theme),
    );
  }

  /// Date lines (starting with %)
  Widget _buildDateContent(ThemeData theme) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SizedBox(
        width: 20,
        height: 24,
        child: DatePickerButton(
            content: entry.content,
            onDatePicked: (dateStr, label) {
              onEntryUpdated!(
                  entry, label == null ? dateStr : "$dateStr - $label");
            }),
      ),
      const SizedBox(width: 16),
      Expanded(
          child: GestureDetector(
              onTap: onTapText,
              child: Text(
                entry.content,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              )))
    ]);
  }

  /// Titles (starting with # or === )
  Widget _buildTitleContent(ThemeData theme) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      SizedBox(
          width: 20,
          height: 30,
          child: Icon(Icons.tag, color: theme.dividerColor)),
      const SizedBox(width: 16),
      Expanded(
          child: GestureDetector(
              onTap: onTapText,
              child: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  // Adjust padding to align with text baseline
                  child: Text(
                    entry.content,
                    style: theme.textTheme.headlineMedium,
                    softWrap: true,
                  ))))
    ]);
  }

  /// Simple line separator
  Widget _buildSeparatorContent(ThemeData theme) {
    return GestureDetector(
        onTap: onTapText,
        child: Divider(color: theme.indicatorColor, thickness: 2.0));
  }

  /// Plain text
  Widget _buildTextContent(ThemeData theme) {
    return GestureDetector(
      onTap: onTapText,
      child: Text(
        entry.content,
        style: theme.textTheme.bodyMedium,
        softWrap: true,
      ),
    );
  }
}
