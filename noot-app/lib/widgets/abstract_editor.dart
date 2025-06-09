import 'package:flutter/material.dart';
import 'package:todo/models/undoredo.dart';
import 'package:todo/utils/preferences_manager.dart';

/// Abstract base class for all editor widgets.
/// This enables a common UI for all editors.
/// What all editors have in common is:
/// - access to the preferences,
/// - callback in case content has changed
/// - scroll position getter/setter
/// - selection getter/setter
/// - possible undo/redo functionality
/// - the need to load a file and to return its current contents
abstract class AbstractEditor extends StatefulWidget {
  /// Preferences
  final PreferenceManager prefs;

  /// Callback when the content has changed.
  final VoidCallback onChanged;

  const AbstractEditor(
      {super.key, required this.prefs, required this.onChanged});
}

abstract class AbstractEditorState extends State<AbstractEditor>
    with UndoRedoHandler {
  /// Scroll controller for the list.
  final ScrollController scrollController = ScrollController();

  /// Load the file from the given [fileUri]. Safe to assume permission
  /// is already granted.
  /// Returns the title [String] of the file.
  Future<String?> loadFile(String fileUri);

  /// Returns the current scroll position in the editor
  double getScrollPosition() {
    return scrollController.offset;
  }

  /// Returns the current caret position in the editor (if any, defaults to 0)
  List<int> getSelection() {
    return [0, 0];
  }

  void setSelection(start, end) {}

  /// Animates smoothly to the given [scrollPosition].
  void scrollTo(double scrollPosition) {
    scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 200),
      curve: Curves.ease,
    );
  }

  /// Resets the editor to an empty state
  void reset();

  /// Returns the content of the editor as a [String].
  Future<String> getContent() async => '';

  @override
  bool supportsUndoRedo() => false;

  @override
  bool canUndo() => false;

  @override
  bool canRedo() => false;

  @override
  void undo() {}

  @override
  void redo() {}
}
