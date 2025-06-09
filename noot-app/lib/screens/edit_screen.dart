import 'dart:convert';

import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo/models/file_item.dart';
import 'package:todo/repository/file_manager.dart';
import 'package:todo/repository/file_monitoring_service.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/utils/preferences_manager.dart';
import 'package:todo/utils/ui_utils.dart';
import 'package:todo/widgets/abstract_editor.dart';
import 'package:todo/widgets/dialogs/confirmation_dialog.dart';
import 'package:todo/widgets/dialogs/edit_mode_dialog.dart';
import 'package:todo/widgets/dialogs/file_changed_dialog.dart';
import 'package:todo/widgets/filename_text.dart';
import 'package:todo/widgets/markdown_editor.dart';
import 'package:todo/widgets/text_editor.dart';
import 'package:todo/widgets/todo_editor.dart';

/// A screen that allows users to edit a to-do file.
/// Can switch between several subscreens:
/// TO-DO (custom list-item based screen)
/// TEXT (flat text editor / code editor)
/// MARKDOWN (rich text editor)
///
class EditScreen extends StatefulWidget {
  /// The file object to edit.
  final FileItem? fileItem;

  /// Preferences
  final PreferenceManager prefs;

  /// Called when the content has been editor by the user.
  final VoidCallback onChanged;

  /// Called when the file has been saved.
  final VoidCallback onSaved;

  const EditScreen({
    super.key,
    required this.fileItem,
    required this.prefs,
    required this.onChanged,
    required this.onSaved,
  });

  @override
  EditScreenState createState() => EditScreenState();
}

/// State class for [EditScreen].
class EditScreenState extends State<EditScreen> with WidgetsBindingObserver {
  /// Platform channel for permissions.
  static const platform =
      MethodChannel('com.droptablecompanies.todo/permissions');

  /// The title of the file.
  String title = '';

  /// Whether a save operation is in progress.
  bool _isSaving = false;

  /// Whether there are unsaved changes.
  bool _hasUnsavedChanges = false;

  /// Whether a save operation has completed.
  bool _saveCompleted = false;

  /// The URI and meta data of the file being edited.
  FileItem? _fileItem;

  /// Current edit mode. Determines if we show the list-based custom editor,
  /// text editor or markdown editor. Determined by the user-defined default
  /// and the last used edit for the selected file.
  EditMode get _editMode =>
      _fileItem?.editMode ??
      (widget.prefs.defaultModeText ? EditMode.text : EditMode.todo);

  set _editMode(EditMode value) {
    _fileItem?.editMode = value;
  }

  /// File manager
  final FileManager _fileManager = FileManager();

  /// Service for monitoring file changes.
  FileMonitorService? _fileMonitor;

  /// Keys to access the editors
  GlobalKey<TodoEditorState> todoScreenKey = GlobalKey<TodoEditorState>();
  GlobalKey<TextEditorState> textScreenKey = GlobalKey<TextEditorState>();
  GlobalKey<MarkdownEditorState> markdownScreenKey =
      GlobalKey<MarkdownEditorState>();

  AbstractEditorState? get currentEditorState {
    switch (_editMode) {
      case EditMode.todo:
        return todoScreenKey.currentState;
      case EditMode.text:
        return textScreenKey.currentState;
      case EditMode.markdown:
        return markdownScreenKey.currentState;
    }
  }

  late AppLocalizations _locale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fileItem = widget.fileItem;
    _fileManager.load();

    // When ready, we load the file and start monitoring it for external changes.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadFile();
      _startMonitoringFile();
    });
  }

  @override
  void dispose() {
    _stopMonitoringFile();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Shows a snackbar with the given [message].
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Loads the file from the given URI.
  Future<void> _loadFile() async {
    final String? fileUri = _fileItem?.uri.toString();
    final scrollPosition = _fileItem?.getScrollPosition() ?? 0.0;
    final selection = _fileItem?.getSelection();

    if (fileUri == null) {
      // debugPrint('No file specified, creating empty list');
      setState(() {
        _hasUnsavedChanges = true;
        currentEditorState?.reset();
        widget.onChanged();
      });
      return;
    }

    title = await currentEditorState?.loadFile(fileUri) ?? '';

    setState(() {
      // Update UI to match state: opened file is saved, no unsaved changes,
      // restore scroll and selection positions (if possible)
      _fileManager.updateTitle(title, fileUri);
      _hasUnsavedChanges = false;
      widget.onSaved();
      if (scrollPosition != 0.0) {
        currentEditorState?.scrollTo(scrollPosition);
      }
      if (selection != null) {
        currentEditorState?.setSelection(selection[0], selection[1]);
      }
    });
  }

  /// Saves the current entries to the file.
  Future<bool> _saveFile() async {
    final String? fileUri = _fileItem?.uri.toString();
    if (fileUri == null) {
      return false;
    }

    setState(() {
      _isSaving = true;
      _saveCompleted = false;
      _hasUnsavedChanges = false;
    });

    // Request storage permission if needed
    if (fileUri.startsWith('content://') != true) {
      final status = await Permission.storage.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Handle permission denial
        _showSnackbar(_locale.storage_permission_denied(fileUri));
        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = true;
        });
        widget.onChanged();
        return false;
      }
    }

    try {
      final String content = await currentEditorState?.getContent() ?? '';

      // Tell the monitor to ignore the next change
      _fileMonitor?.ignoreNextChange();

      await ContentResolver.writeContent(
          fileUri, Uint8List.fromList(utf8.encode(content)));

      // Continue monitoring
      if (_fileMonitor?.isMonitoring() == false) {
        if (_fileMonitor != null) {
          _fileMonitor?.startMonitoring();
        } else {
          _startMonitoringFile();
        }
      }
      // Done!
      widget.onSaved();
      _showSnackbar(_locale.file_saved);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      _showSnackbar(_locale.file_write_failed_uri(fileUri));
      setState(() {
        _hasUnsavedChanges = true;
      });
      widget.onChanged();
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveCompleted = true;
        });
      }

      await storeScrollPosition();
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _saveCompleted = false;
        });
      }
    }
  }

  /// Starts monitoring the file for external changes.
  void _startMonitoringFile() {
    final String? fileUri = _fileItem?.uri.toString();
    if (fileUri == null) {
      return;
    }

    _fileMonitor = FileMonitorService(
      fileUri: fileUri,
      onFileChanged: () => _handleExternalModification(false),
      checkInterval: const Duration(seconds: 5),
      onFileDeleted: () => _handleExternalModification(true),
    );

    _fileMonitor?.startMonitoring();
  }

  /// Stops monitoring the file for external changes.
  void _stopMonitoringFile() {
    _fileMonitor?.stopMonitoring();
  }

  /// Builds the save button with different states.
  /// Shows when there are unsaved changes, shows a progress spinner while saving,
  /// briefly shows a checkmark when done, and hides when all is well.
  Widget _buildSaveButton(StateColors colors) {
    if (_isSaving) {
      return CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(colors.taskUnderDiscussionIcon),
      );
    } else if (_saveCompleted) {
      return Padding(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.check_rounded, color: colors.ok),
      );
    } else if (_hasUnsavedChanges) {
      return IconButton(
        icon: Icon(Icons.save_rounded, color: colors.taskRejectedIcon),
        onPressed: () => _saveFile(),
      );
    } else {
      return Container();
    }
  }

  /// The overflow menu is basically only the edit mode button,
  /// but with room for more in the future.
  Widget _buildOverflowMenu(ThemeData theme, StateColors colors) {
    if (isTablet(context)) {
      return IconButton(
          icon: Icon(Icons.edit_note_rounded, color: colors.warning),
          onPressed: () => _onEditModeTapped());
    } else {
      return PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: colors.icons),
        constraints: const BoxConstraints.tightFor(width: 300),
        onSelected: (newMode) {
          // setState(() {
          //   _editMode = newMode;
          // });
          // WidgetsBinding.instance.addPostFrameCallback((_) async {
          //   await _loadFile();
          // });
        },
        itemBuilder: (BuildContext context) {
          return [
            _buildEditModeButton(theme, colors),
          ];
        },
      );
    }
  }

  /// Stores the current scroll position.
  Future<void> storeScrollPosition() async {
    final String? fileUri = _fileItem?.uri.toString();
    final scrollPosition = currentEditorState?.getScrollPosition() ?? 0.0;
    final selection = currentEditorState?.getSelection() ?? [0, 0];
    debugPrint(
        'Storing scroll position $scrollPosition and selection $selection');
    await _fileManager.updateScrollOffset(
        fileUri, scrollPosition, selection[0], selection[1], _editMode);
  }

  Future<bool> _onBackPressed(BuildContext context) async {
    await storeScrollPosition();

    // This will trigger when the user closes the keyboard. We
    // don't want to exit at that point yet, so we return false
    if ((_editMode == EditMode.text || _editMode == EditMode.markdown) &&
        context.mounted) {
      final keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
      if (keyboardVisible) {
        FocusManager.instance.primaryFocus?.unfocus();
        return false;
      }
    }

    // Close without warning if there are no unsaved changes
    if (!_hasUnsavedChanges) {
      return true;
    }

    // Autosave if enabled
    // if (widget.prefs.autosave) {
    //   if (await _saveFile()) {
    //     return true;
    //   }
    // }

    return context.mounted &&
        await showDialog(
          context: context,
          builder: (context) => ConfirmationDialog(
            title: _locale.confirm,
            content: _locale.confirm_discard_changes,
            onConfirmed: () => Navigator.of(context).pop(true),
            onCancelled: () => Navigator.of(context).pop(false),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    _locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.extension<StateColors>()!;
    return Scaffold(
        appBar: AppBar(
          elevation: 4.0,
          title: FileNameText(fileName: title),
          actions: [
            if (currentEditorState?.supportsUndoRedo() == true)
              ..._buildUndoRedoButtons(theme, colors),
            _buildSaveButton(colors),
            // _buildSearchButton(),
            _buildOverflowMenu(theme, colors),
          ],
        ),
        body: PopScope(
            canPop: !_hasUnsavedChanges,
            onPopInvokedWithResult: (didPop, result) async {
              if (!didPop) {
                if (await _onBackPressed(context) && context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child:
                CallbackShortcuts(bindings: <ShortcutActivator, VoidCallback>{
              SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
                _saveFile();
              },
              SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
                currentEditorState?.undo();
              },
              SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
                currentEditorState?.redo();
              },
            }, child: Focus(autofocus: true, child: _buildEditor()))));
  }

  /// Handles external modifications to the file.
  void _handleExternalModification(bool isDeleted) async {
    if (!_hasUnsavedChanges && !isDeleted) {
      _loadFile();
      _showSnackbar(_locale.file_updated);
    } else {
      _fileMonitor?.stopMonitoring();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return FileChangedDialog(
            isDeleted: isDeleted,
            onReload: () async {
              Navigator.of(context).pop();
              await _loadFile();
              _fileMonitor?.startMonitoring();
            },
            onKeepEditing: () {
              // Make sure we go into 'new file' mode
              _fileItem = null;

              Navigator.of(context).pop();
              setState(() {
                _hasUnsavedChanges = true;
              });
              widget.onChanged();
            },
          );
        },
      );
    }
  }

  /// EditMode button opens the dialog to switch between editors
  PopupMenuEntry<String> _buildEditModeButton(
      ThemeData theme, StateColors colors) {
    final modes = [_locale.mode_todo, _locale.mode_text, _locale.mode_markdown];
    return PopupMenuItem<String>(
      value: "edit_mode",
      child: ListTile(
          leading: Icon(Icons.edit_note_rounded, color: colors.warning),
          title: Text(_locale.edit_mode(modes[_editMode.index]),
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: _hasUnsavedChanges ? colors.dimmed : colors.text),
              softWrap: false)),
      onTap: () {
        _onEditModeTapped();
      },
    );
  }

  /// Shows the editor mode dialog.
  /// Only works when there are no unsaved changes, because switching editors
  /// involves reloading the file from disk.
  Future<void> _onEditModeTapped() async {
    if (!_hasUnsavedChanges) {
      final selectedMode = await showDialog<EditMode>(
        context: context,
        builder: (BuildContext context) {
          return EditModeDialog(
            currentMode: _editMode,
          );
        },
      );

      if (selectedMode != null && selectedMode != _editMode) {
        setState(() {
          _editMode = selectedMode;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadFile();
        });
      }
    }
  }

  void _onChanged() {
    if (!_hasUnsavedChanges) {
      storeScrollPosition();
      setState(() {
        _hasUnsavedChanges = true;
      });
      widget.onChanged();
    }
  }

  /// Builds one of 3 actual editors
  Widget _buildEditor() {
    switch (_editMode) {
      case EditMode.text:
        return TextEditor(
          key: textScreenKey,
          prefs: widget.prefs,
          onChanged: () {
            _onChanged();
          },
        );
      case EditMode.markdown:
        return MarkdownEditor(
          key: markdownScreenKey,
          prefs: widget.prefs,
          onChanged: () {
            _onChanged();
          },
        );
      default:
        return TodoEditor(
          key: todoScreenKey,
          prefs: widget.prefs,
          onChanged: () {
            _onChanged();
          },
        );
    }
  }

  _buildUndoRedoButtons(ThemeData theme, StateColors colors) {
    return [
      IconButton(
        icon: const Icon(Icons.undo_rounded),
        onPressed: currentEditorState?.canUndo() == true
            ? () {
                currentEditorState?.undo();
                // Extra onchanged to make sure the editor knows
                // that Redo should be enabled now
                widget.onChanged();
              }
            : null,
        tooltip: _locale.undo,
      ),
      IconButton(
        icon: const Icon(Icons.redo_rounded),
        onPressed: currentEditorState?.canRedo() == true
            ? () {
                currentEditorState?.redo();
                // Extra unchanged to make sure the editor knows
                // that Undo should be enabled now
                widget.onChanged();
              }
            : null,
        tooltip: _locale.redo,
      ),
    ];
  }
}
