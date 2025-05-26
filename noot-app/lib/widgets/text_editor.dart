import 'dart:convert';

import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/utils/todo_syntax.dart';
import 'package:todo/widgets/abstract_editor.dart';

/// Editor for plain text or code.
/// Shows a monospaces text editor with optional syntax highlighting
/// (for To-do files and Markdown only at the moment).
class TextEditor extends AbstractEditor {
  const TextEditor({super.key, required super.prefs, required super.onChanged})
      : super();

  @override
  TextEditorState createState() => TextEditorState();
}

/// Analyzer that does nothing, because we need to pass something to the
/// CodeController.
class NullAnalyzer extends AbstractAnalyzer {
  NullAnalyzer();

  final nothing = AnalysisResult(issues: []);

  @override
  Future<AnalysisResult> analyze(Code code) async {
    return nothing;
  }
}

/// State class for [TextEditor].
class TextEditorState extends AbstractEditorState {
  final _controller = CodeController(
      text: '',
      language: null,
      analyzer: NullAnalyzer(),
      enableFolding: false,
      modifiers: [],
      params: EditorParams(tabSpaces: 4));

  final FocusNode textEditorFocusNode = FocusNode();

  /// Autocomplete is disabled, because it is not a standard one but a custom
  /// one that does not fit our needs.
  final bool _autoComplete = false;

  /// Wrapping is enabled, which disables the line numbers
  final bool _wrap = true;
  final bool _gutter = false;

  final _enableUndoRedo = true;

  @override
  bool supportsUndoRedo() => _enableUndoRedo;

  @override
  // TODO this should be determined by the historyController, but
  //  that is not supported yet and would require yet another edit in the package
  bool canUndo() => true;

  @override
  bool canRedo() => true;

  @override
  void undo() => _controller.historyController.undo();

  @override
  void redo() => _controller.historyController.redo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<StateColors>()!;
    return Theme(
        data: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.background,
        )),
        child: CodeTheme(
            data: CodeThemeData(styles: monokaiSublimeTheme),
            child: SingleChildScrollView(
                controller: super.scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: CodeField(
                  background: colors.background,
                  cursorColor: Colors.blue,
                  focusNode: textEditorFocusNode,
                  gutterStyle: _gutter
                      ? GutterStyle(
                          background: colors.background,
                          showErrors: false,
                          showFoldingHandles: false,
                          width: 80.0)
                      : GutterStyle.none,
                  controller: _controller,
                  maxLines: null,
                  wrap: _wrap,
                  textStyle: theme.textTheme.bodyMedium,
                  onChanged: (content) {
                    widget.onChanged();
                  },
                ))));
  }

  @override
  Future<String?> loadFile(String fileUri) async {
    final content = await ContentResolver.resolveContent(fileUri);
    final title = content.fileName ?? 'Untitled';

    setState(() {
      _controller.fullText = utf8.decode(content.data);
      _controller.popupController.enabled = _autoComplete;
      // Auto-detect the correct syntax highlighter based on the extension
      // and the user's preferences:
      if (widget.prefs.enableSyntax) {
        if (content.fileName!.endsWith(".md")) {
          _controller.language = markdown;
        } else if (content.fileName!.endsWith(".todo") ||
            content.fileName!.endsWith(".todo.txt") ||
            content.fileName!.endsWith(".journal.txt")) {
          _controller.language = todo;
        } else if (content.fileName!.endsWith(".txt")) {
          if (widget.prefs.txtIsMarkdown) {
            _controller.language = markdown;
          } else {
            _controller.language = todo;
          }
        } else {
          _controller.language = null;
        }
      } else {
        _controller.language = null;
      }
    });
    return title;
  }

  @override
  List<int> getSelection() {
    return [_controller.selection.start, _controller.selection.end];
  }

  @override
  void setSelection(start, end) {
    setState(() {
      if (start == end || start > end) {
        _controller.setCursor(start);
      } else {
        _controller.selection =
            TextSelection(baseOffset: start, extentOffset: end);
      }
      textEditorFocusNode.requestFocus();
    });
  }

  @override
  void reset() {
    setState(() {
      _controller.fullText = '';
    });
  }

  @override
  String getContent() {
    return _controller.fullText;
  }
}
