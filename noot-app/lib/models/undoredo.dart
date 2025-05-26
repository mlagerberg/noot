import 'package:todo/models/models.dart';
import 'package:todo/widgets/todo_editor.dart';

/// Command interface for undo/redo operations
abstract class Command {
  void execute();

  void undo();
}

abstract mixin class UndoRedoHandler {
  /// Undo the last command
  void undo();

  /// Redo the last undone command
  void redo();

  /// Check if the editor supports undo/redo
  bool supportsUndoRedo();

  /// Check if the editor can undo (based on [supportsUndoRedo] and if there are commands to undo)
  bool canUndo();

  /// Check if the editor can redo (based on [supportsUndoRedo] and if there are commands to redo)
  bool canRedo();
}

/// Command for adding an entry
class AddEntryCommand implements Command {
  final TodoEditorState state;
  final Entry entry;
  final int index;

  AddEntryCommand(this.state, this.entry, this.index);

  @override
  void execute() {
    state.entries.insert(index, entry);
    state.notifyChanged();
  }

  @override
  void undo() {
    state.entries.removeAt(index);
    state.notifyChanged();
  }
}

/// Command for removing an entry
class RemoveEntryCommand implements Command {
  final TodoEditorState state;
  final Entry entry;
  final int index;

  RemoveEntryCommand(this.state, this.entry, this.index);

  @override
  void execute() {
    state.entries.removeAt(index);
    state.notifyChanged();
  }

  @override
  void undo() {
    state.entries.insert(index, entry);
    state.notifyChanged();
  }
}

/// Command for updating an entry
class UpdateEntryCommand implements Command {
  final TodoEditorState state;
  final Entry oldEntry;
  final Entry newEntry;
  final int index;

  UpdateEntryCommand(this.state, this.oldEntry, this.newEntry, this.index);

  @override
  void execute() {
    state.entries[index] = newEntry;
    state.notifyChanged();
  }

  @override
  void undo() {
    state.entries[index] = oldEntry;
    state.notifyChanged();
  }
}

/// Command for reordering entries
class ReorderEntryCommand implements Command {
  final TodoEditorState state;
  List<Entry> entriesBeforeReorder;
  final Function operation;

  ReorderEntryCommand(this.state, this.operation)
      : entriesBeforeReorder = List.from(state.entries);

  @override
  void execute() {
    operation();
  }

  @override
  void undo() {
    state.entries =
        List<Entry>.from(entriesBeforeReorder.map((e) => Entry.from(e)));
    state.notifyChanged();
  }
}

/// Command for clipboard operations (cut, paste)
class ClipboardCommand implements Command {
  final TodoEditorState state;
  final List<Entry> entriesBeforeOperation;
  final Function operation;

  ClipboardCommand(this.state, this.operation)
      : entriesBeforeOperation =
            List<Entry>.from(state.entries.map((e) => Entry.from(e)));

  @override
  void execute() {
    operation();
  }

  @override
  void undo() {
    state.entries =
        List<Entry>.from(entriesBeforeOperation.map((e) => Entry.from(e)));
    state.notifyChanged();
  }
}
