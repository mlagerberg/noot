import 'dart:convert';

import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/utils/todo_syntax.dart';
import 'package:todo/widgets/abstract_editor.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  final FocusNode textEditorFocusNode = FocusNode();

  final _enableUndoRedo = false;

  late WebViewController _controller;
  bool _ready = false;
  // Holds the content in case the editor is not ready
  String? _content;

  // @override
  // bool supportsUndoRedo() => _enableUndoRedo;
  //
  // @override
  // bool canUndo() => true;
  //
  // @override
  // bool canRedo() => true;
  //
  // @override
  // void undo() => _controller.runJavaScript("undo()");
  //
  // @override
  // void redo() => _controller.runJavaScript("redo()");

  @override
  initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("WebView is loading (progress : $progress%)");
          },
          onPageStarted: (String url) {
            debugPrint("WebView is starting");
          },
          onPageFinished: (String url) {
            debugPrint("WebView is finished");
            _ready = true;
            if (_content != null) {
              _setContent(_content!);
              _content = null;
            }
          },
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadFlutterAsset('assets/editor.html');
  }

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
      child: WebViewWidget(controller: _controller),
    );
  }

  Future<void> _setContent(String content) async {
    if (!_ready) {
      _content = content;
      return;
    }
    final escaped = Uri.encodeFull(content);
    await _controller.runJavaScript('setValue("$escaped")');
  }

  @override
  Future<String?> loadFile(String fileUri) async {
    final content = await ContentResolver.resolveContent(fileUri);
    final title = content.fileName ?? 'Untitled';
    await _setContent(utf8.decode(content.data));

    setState(() {
      // Auto-detect the correct syntax highlighter based on the extension
      // and the user's preferences:
      // if (widget.prefs.enableSyntax) {
      //   if (content.fileName!.endsWith(".md")) {
      //     _controller.language = markdown;
      //   } else if (content.fileName!.endsWith(".todo") ||
      //       content.fileName!.endsWith(".todo.txt") ||
      //       content.fileName!.endsWith(".journal.txt")) {
      //     _controller.language = todo;
      //   } else if (content.fileName!.endsWith(".txt")) {
      //     if (widget.prefs.txtIsMarkdown) {
      //       _controller.language = markdown;
      //     } else {
      //       _controller.language = todo;
      //     }
      //   } else {
      //     _controller.language = null;
      //   }
      // } else {
      //   _controller.language = null;
      // }
    });
    return title;
  }

  @override
  List<int> getSelection() {
    // return [_controller.selection.start, _controller.selection.end];
    return [0,0];
  }

  @override
  void setSelection(start, end) {
    setState(() {
      // if (start == end || start > end) {
      //   _controller.setCursor(start);
      // } else {
      //   _controller.selection =
      //       TextSelection(baseOffset: start, extentOffset: end);
      // }
      textEditorFocusNode.requestFocus();
    });
  }

  @override
  void reset() {
    _setContent('');
    setState(() {});
  }

  @override
  Future<String> getContent() async {
    final content = (await _controller.runJavaScriptReturningResult('getValue()')) as String;
    return Uri.decodeFull(content);
  }
}
