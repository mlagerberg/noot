import 'dart:convert';

import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/models.dart';
import 'package:todo/models/undoredo.dart';
import 'package:todo/repository/formatter.dart';
import 'package:todo/repository/parser.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/utils/date_util.dart';
import 'package:todo/utils/ui_utils.dart';
import 'package:todo/widgets/abstract_editor.dart';
import 'package:todo/widgets/dialogs/confirmation_dialog.dart';
import 'package:todo/widgets/dialogs/entry_edit_dialog.dart';
import 'package:todo/widgets/entry_widget.dart';

/// The main editor type of this app. Used for To-do files.
/// Instead of using text-based editing, each line in the file is translated
/// to a list item ([EntryWidget]) with its own styling and actions.
/// Lines can be dragged, swiped away, etc.
///
/// Since this is not a standard editor, we implement our own undo/redo for all
/// operations, as well as our own copy/paste operations.
class TodoEditor extends AbstractEditor {
  const TodoEditor({super.key, required super.prefs, required super.onChanged});

  @override
  TodoEditorState createState() => TodoEditorState();
}

/// State class for [TodoEditor].
class TodoEditorState extends AbstractEditorState {
  /// List of entries being edited.
  List<Entry> entries = [];

  late AppLocalizations _locale;

  // Undo/redo stacks
  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  // Clipboard for cut/copy/paste operations
  // Entry? _clipboardEntry;
  bool _hasClipboardContent = false;

  // Execute a command and add it to the undo stack
  void executeCommand(Command command) {
    command.execute();
    _undoStack.add(command);
    // Clear redo stack when a new command is executed
    _redoStack.clear();
    widget.onChanged();
  }

  @override
  bool supportsUndoRedo() => true;

  @override
  bool canUndo() => _undoStack.isNotEmpty;

  @override
  bool canRedo() => _redoStack.isNotEmpty;

  @override
  void undo() {
    if (canUndo()) {
      final command = _undoStack.removeLast();
      command.undo();
      _redoStack.add(command);
      notifyChanged();
    }
  }

  /// Redo the last undone command
  @override
  void redo() {
    if (canRedo()) {
      final command = _redoStack.removeLast();
      command.execute();
      _undoStack.add(command);
      notifyChanged();
    }
  }

  /// Helper to notify that changes were made
  void notifyChanged() {
    setState(() {});
    widget.onChanged();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _hasClipboardContent = await isClipboardNotEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    _locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.extension<StateColors>()!;
    final useTabletLayout = isTablet(context);

    return Scrollbar(
      controller: scrollController,
      thickness: 8.0,
      radius: const Radius.circular(8),
      scrollbarOrientation: ScrollbarOrientation.right,
      child: ReorderableListView.builder(
        scrollController: scrollController,
        padding: EdgeInsets.only(bottom: 96.0),
        itemCount: entries.length,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: colors.backgroundLighter,
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Padding(
              key: Key('$index'),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Dismissible(
                key: Key('$index-dm'),
                direction: widget.prefs.enableSwipe != false
                    ? DismissDirection.horizontal
                    : DismissDirection.none,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Handle swipe to the right (e.g., mark as completed)
                    if (entry.isTask()) {
                      final oldEntry = Entry.from(entry);
                      final newEntry = Entry.from(entry);
                      newEntry.state =
                          entry.isDone() ? TaskState.open : TaskState.done;
                      executeCommand(
                          UpdateEntryCommand(this, oldEntry, newEntry, index));
                    }
                  } else if (direction == DismissDirection.endToStart) {
                    // Handle swipe to the left (delete)
                    if (await _confirmDeleteEntry(index, false)) {
                      // FIXME this should return true and do the actual deletion in the onDismissed
                      _deleteEntry(index);
                    }
                  }
                  return false;
                },
                onDismissed: (direction) {
                  // FIXME see the fixme above
                  // if (direction == DismissDirection.endToStart) {
                  //   _deleteEntry(index);
                  // }
                },
                background: Container(
                  color: colors.backgroundLighter,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: entry.isDone()
                          ? Icon(Icons.circle_outlined, color: colors.dimmed)
                          : Icon(Icons.check_circle, color: colors.ok),
                    ),
                  ),
                ),
                secondaryBackground: Container(
                  color: colors.error,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                child: EntryWidget(
                  index: index,
                  entry: entry,
                  useTabletLayout: useTabletLayout,
                  onTapIcon: entry.type == EntryType.task ||
                          entry.type == EntryType.subtask
                      ? (TaskState newState) {
                          _setTaskState(entry, newState, index);
                        }
                      : null,
                  onTapText: () => _editEntryContent(entry, index),
                  onEntryUpdated: (entry, content) =>
                      _updateEntryContent(entry, content, index),
                  onDelete: () => _confirmDeleteEntry(index, true),
                  onInsertBelow: () => _insertEntryAfter(index),
                  onInsertChild: () => _insertEntryChild(index),
                  onInsertAbove: () => _insertEntryBefore(index),
                  onInsertDateAbove: () => _insertDateBefore(index),
                  onCut: () => _cutEntry(index),
                  onCopy: () => _copyEntry(index),
                  onPasteAbove: () => _pasteEntry(index, true),
                  onPasteBelow: () => _pasteEntry(index, false),
                  canPaste: _hasClipboardContent,
                ),
              ));
        },
        onReorder: _reorderEntry,
      ),
    );
  }

  @override
  Future<String?> loadFile(String fileUri) async {
    final parser = Parser();
    final content = await ContentResolver.resolveContent(fileUri);
    final parsedContent = parser.parse(_locale, utf8.decode(content.data));
    final title = content.fileName ?? _locale.untitled;

    setState(() {
      entries = parsedContent;
      // Clear command stacks when loading a new file
      _undoStack.clear();
      _redoStack.clear();
    });

    return title;
  }

  @override
  void reset() {
    setState(() {
      entries = [Entry.blank()];
      // Clear command stacks when resetting
      _undoStack.clear();
      _redoStack.clear();
    });
  }

  @override
  String getContent() {
    final formatter = Formatter();
    final content = entries.map((e) => formatter.entryToString(e)).join('\n');
    return content;
  }

  Future<bool> isClipboardNotEmpty() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data != null && data.text != null && data.text!.isNotEmpty;
  }

  /// Cut an entry to clipboard
  void _cutEntry(int index) {
    final entry = entries[index];

    // Serialize the entry using the standard formatter, and copy to clipboard
    Clipboard.setData(ClipboardData(text: Formatter().entryToString(entry)));

    // Create a command for this operation
    executeCommand(ClipboardCommand(this, () {
      entries.removeAt(index);

      // Ensure there's always at least one entry
      if (entries.isEmpty) {
        entries.add(Entry.blank());
      }
    }));

    setState(() {
      _hasClipboardContent = true;
    });
  }

  /// Copy an entry to clipboard
  void _copyEntry(int index) {
    final entry = entries[index];

    // Serialize the entry using the standard formatter, and copy to clipboard
    Clipboard.setData(ClipboardData(text: Formatter().entryToString(entry)));
    setState(() {
      _hasClipboardContent = true;
    });
  }

  /// Paste an entry from clipboard
  void _pasteEntry(int index, bool above) async {
    // Get the content of the clipboard
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;

    // Parse the clipboard content using the default parser
    final pasteIndex = above ? index : index + 1;
    final entryToPaste = Parser().parse(_locale, data!.text ?? '');

    if (entryToPaste.length == 1) {
      // Create a command for this operation
      if (entryToPaste[0].type == EntryType.text) {
        // If no formatting is detected, lets make it a task
        entryToPaste[0].type = EntryType.task;
        entryToPaste[0].state = TaskState.open;
      }
      executeCommand(AddEntryCommand(this, entryToPaste[0], pasteIndex));
    } else {
      final plainTextItem =
          Entry(type: EntryType.text, content: data.text ?? '');
      executeCommand(AddEntryCommand(this, plainTextItem, pasteIndex));
    }
  }

  /// Deletes an entry at the given [index].
  void _deleteEntry(int index) {
    final removedEntry = Entry.from(entries[index]);
    executeCommand(RemoveEntryCommand(this, removedEntry, index));
    // Ensure there's always at least one entry
    if (entries.isEmpty) {
      // FIXME This inserts a second undo entry, which we might want to fix
      executeCommand(AddEntryCommand(this, Entry.blank(), 0));
    }
  }

  Future<bool> _confirmDeleteEntry(int index, bool forceConfirm) async {
    if (widget.prefs.confirmDiscard || forceConfirm) {
      return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            title: _locale.delete_entry,
            content: _locale.delete_entry_confirm,
            onConfirmed: () {
              Navigator.of(context).pop(true);
            },
            onCancelled: () {
              Navigator.of(context).pop(false);
            },
          );
        },
      );
    } else {
      return true;
    }
  }

  /// Reorders an entry from [oldIndex] to [newIndex].
  void _reorderEntry(int oldIndex, int newIndex) {
    // Save the state before reordering for undo
    final command = ReorderEntryCommand(this, () {
      final movedEntry = entries[oldIndex];
      entries.removeAt(oldIndex);
      // New index might've shifted by the removal, so adjust for that
      int shift = (oldIndex < newIndex) ? -1 : 0;
      newIndex += shift;
      newIndex = newIndex.clamp(0, entries.length);

      // Insert entry at the new spot
      entries.insert(newIndex, movedEntry);

      // Move it's child elements too
      if (movedEntry.type == EntryType.task) {
        final childEntries = <Entry>[];

        // Collect child entries (must follow the moved entry and belong to it)
        int currentIndex = oldIndex +
            shift +
            1; // Adjusted index after the removal of `movedEntry`
        while (currentIndex < entries.length) {
          final child = entries[currentIndex];
          if (child.type == EntryType.subtask &&
              child.parentTask == movedEntry) {
            childEntries.add(child);
            // Remove from old position
            entries.removeAt(currentIndex);
            if (currentIndex < newIndex) {
              shift -= 1;
            }
          } else {
            break; // Stop collecting once non-child entries are found
          }
        }

        // Insert child entries directly after the moved entry
        if (oldIndex < newIndex) {
          shift += 1;
        }
        for (var i = 0; i < childEntries.length; i++) {
          final insertIndex =
              (newIndex + shift + i + 1).clamp(0, entries.length);
          entries.insert(insertIndex, childEntries[i]);
          childEntries[i].refreshDisplayState();
        }

        // If there are more subtasks after this index, they have a new parent
        for (var i = newIndex + shift + 1; i < entries.length; i++) {
          if (entries[i].type == EntryType.subtask) {
            entries[i].parentTask = movedEntry;
            entries[i].refreshDisplayState();
          } else {
            break;
          }
        }
      } else if (movedEntry.type == EntryType.subtask) {
        // Update display state if parent has changed
        if (newIndex > 0 && entries[newIndex - 1].type == EntryType.task) {
          movedEntry.parentTask = entries[newIndex - 1];
        } else if (newIndex > 0 &&
            entries[newIndex - 1].type == EntryType.subtask) {
          movedEntry.parentTask = entries[newIndex - 1].parentTask;
        }
        movedEntry.refreshDisplayState();
      }

      notifyChanged();
    });

    command.execute();

    // Add the reorder command to the undo stack
    _undoStack.add(command);
    _redoStack.clear();
  }

  /// Inserts a new entry after the given [index].
  void _insertEntryAfter(int index) {
    final currentType = entries[index].type;
    var newType = EntryType.text;
    Entry? parent;
    if (currentType == EntryType.task || currentType == EntryType.date) {
      newType = EntryType.task;
    } else if (currentType == EntryType.subtask) {
      newType = EntryType.subtask;
      parent = entries[index].parentTask;
    }

    final newEntry = Entry(type: newType, content: '', state: TaskState.open);
    newEntry.parentTask = parent;
    newEntry.refreshDisplayState();

    executeCommand(AddEntryCommand(this, newEntry, index + 1));

    if (newType != EntryType.text) {
      _editEntryContent(entries[index + 1], index + 1);
    }
  }

  /// Inserts a new entry after the given [index], always a subtask
  void _insertEntryChild(int index) {
    Entry parent = entries[index];
    var newType = EntryType.subtask;
    final newEntry = Entry(type: newType, content: '', state: TaskState.open);
    newEntry.parentTask = parent;
    newEntry.refreshDisplayState();

    executeCommand(AddEntryCommand(this, newEntry, index + 1));
    _editEntryContent(entries[index + 1], index + 1);
  }

  /// Inserts a new entry before the given [index].
  void _insertEntryBefore(int index) {
    final newEntry =
        Entry(type: EntryType.task, content: '', state: TaskState.open);
    executeCommand(AddEntryCommand(this, newEntry, index));
  }

  /// Inserts multiple new entries befor
  /// e the given [index].
  void _insertDateBefore(int index) {
    final entry = entries[index];
    final dateUtil = DateUtil();
    final date = dateUtil.parseLine(entry.content).$1;
    final dateEntry = Entry(
        type: EntryType.date,
        content: dateUtil.formatDate(
            widget.prefs.dateFormat, date.add(Duration(days: 1))));
    executeCommand(AddEntryCommand(
        this, Entry(type: EntryType.empty, content: ''), index));
    if (date.weekday == DateTime.sunday) {
      executeCommand(AddEntryCommand(
          this, Entry(type: EntryType.separator, content: ''), index));
      executeCommand(AddEntryCommand(
          this, Entry(type: EntryType.empty, content: ''), index));
    }
    executeCommand(AddEntryCommand(
        this,
        Entry(type: EntryType.task, state: TaskState.open, content: ''),
        index));
    executeCommand(AddEntryCommand(this, dateEntry, index));
    executeCommand(AddEntryCommand(
        this, Entry(type: EntryType.empty, content: ''), index));
  }

  /// Sets the [newState] for a task [entry] at [index].
  void _setTaskState(Entry entry, TaskState newState, int index) {
    final oldEntry = Entry.from(entry);
    final newEntry = Entry.from(entry);
    newEntry.state = newState;

    executeCommand(UpdateEntryCommand(this, oldEntry, newEntry, index));

    setState(() {
      entry.state = newState;

      // Refresh subtasks
      for (int i = index + 1; i < entries.length; i++) {
        if (entries[i].type == EntryType.subtask &&
            entries[i].parentTask == entry) {
          entries[i].parentTask = entry;
          entries[i].refreshDisplayState();
        } else {
          break; // Stop if we encounter a non-subtask entry
        }
      }
    });
  }

  /// Edits the content of an [entry] at [index].
  void _editEntryContent(Entry entry, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EntryEditDialog(
          entry: entry,
          onSave: (updatedEntry) {
            executeCommand(
                UpdateEntryCommand(this, entry, updatedEntry, index));
          },
        );
      },
    );
  }

  /// Updates the [entry] at [index] with the new [content].
  void _updateEntryContent(Entry entry, String content, int index) {
    final oldEntry = Entry.from(entry);
    final newEntry = Entry.from(entry);
    newEntry.content = content;

    executeCommand(UpdateEntryCommand(this, oldEntry, newEntry, index));

    setState(() {
      entry.content = content;
    });
  }
}
