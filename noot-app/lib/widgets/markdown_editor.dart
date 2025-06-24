import 'dart:convert';

import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_markdown/super_editor_markdown.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/theme/theme.dart';
import 'package:todo/widgets/abstract_editor.dart';

/// Rich teext editor for Markdown files. Uses the Super-Editor.
class MarkdownEditor extends AbstractEditor {
  const MarkdownEditor(
      {super.key, required super.prefs, required super.onChanged})
      : super();

  @override
  MarkdownEditorState createState() => MarkdownEditorState();
}

/// State class for [MarkdownEditor].
class MarkdownEditorState extends AbstractEditorState {
  final FocusNode textEditorFocusNode = FocusNode();

  late final MutableDocumentComposer _composer;
  Editor? _editor;
  bool _hasLinefeeds = false;

  final _enableUndoRedo = true;

  @override
  bool supportsUndoRedo() => _enableUndoRedo;

  @override
  bool canUndo() => _editor?.history.isNotEmpty == true;

  @override
  bool canRedo() => _editor?.future.isNotEmpty == true;

  @override
  void undo() => _editor?.undo();

  @override
  void redo() => _editor?.redo();

  @override
  void initState() {
    super.initState();
    _composer = MutableDocumentComposer();
    _createEmptyDoc();
  }

  @override
  Future<String?> loadFile(String fileUri) async {
    final locale = AppLocalizations.of(context)!;
    final content = await ContentResolver.resolveContent(fileUri);
    final title = content.fileName ?? locale.untitled;

    setState(() {
      final contentStr = utf8.decode(content.data);
      // Remember if we should restore the original linebreaks.
      _hasLinefeeds = contentStr.contains('\n\r');
      final document = deserializeMarkdownToDocument(contentStr);
      document.addListener(_onDocumentChange);
      _editor = createDefaultDocumentEditor(
        document: document,
        composer: _composer,
        isHistoryEnabled: _enableUndoRedo,
      );
    });
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<StateColors>()!;
    return Container(
        color: widget.prefs.forceBrightModeMarkdown
            ? AppTheme.bright_background
            : colors.background,
        child: _editor == null
            ? Container()
            : Theme(
                data: ThemeData(
                    textSelectionTheme: TextSelectionThemeData(
                        cursorColor: widget.prefs.forceBrightModeMarkdown
                            ? AppTheme.bright_text
                            : colors.text)),
                child: SuperEditor(
                    editor: _editor!,
                    scrollController: super.scrollController,
                    stylesheet: _createStyles(colors, defaultStylesheet),
                    androidHandleColor: colors.url,
                    selectionStyle:
                        SelectionStyles(selectionColor: colors.date),
                    imeConfiguration: const SuperEditorImeConfiguration(
                      enableAutocorrect: false,
                      enableSuggestions: true,
                    )
                    // focusNode: textEditorFocusNode,
                    )));
  }

  @override
  List<int> getSelection() {
    // We return this for now, since selection depends on nodes in a document
    // tree and don't easily translate to start/end indices. See also below.
    return [0, 0];
  }

  @override
  void setSelection(start, end) {
    setState(() {
      // TODO to implement getting and setting selection, we need to store more
      //  than an int.
      // We need the node ID and node position in the document:
      // _composer.selection.start.nodeId
      // _composer.selection.start.nodePosition;
      textEditorFocusNode.requestFocus();
    });
  }

  @override
  void reset() {
    setState(() {
      _createEmptyDoc();
    });
  }

  @override
  Future<String> getContent() async {
    if (_editor == null) {
      return '';
    }
    final contentStr = serializeDocumentToMarkdown(_editor!.context.document);
    if (!_hasLinefeeds) {
      return contentStr.replaceAll('\n\r', '\n');
    }
    return contentStr;
  }

  /// Several customizations over the default styles of the editor.
  /// Includes more modest H1 font size, custom typefaces, and
  /// paragraphs justification.
  Stylesheet _createStyles(StateColors colors, Stylesheet defaultStylesheet) {
    final myRules = [
      StyleRule(
        BlockSelector.all,
        (doc, docNode) {
          return {
            Styles.textStyle: TextStyle(
                fontFamily: 'monospace',
                color: widget.prefs.forceBrightModeMarkdown
                    ? AppTheme.bright_text
                    : colors.text),
          };
        },
      ),
      StyleRule(
        const BlockSelector("paragraph"),
        (doc, docNode) {
          return {
            Styles.textStyle: const TextStyle(
              fontFamily: 'Merriweather',
            ),
            Styles.textAlign: TextAlign.justify
          };
        },
      ),
      StyleRule(
        const BlockSelector("listItem"),
        (doc, docNode) {
          return {
            Styles.textStyle: const TextStyle(
              fontFamily: 'Merriweather',
            ),
            Styles.textAlign: TextAlign.justify
          };
        },
      ),
      StyleRule(
        const BlockSelector("header1"),
        (doc, docNode) {
          return {
            Styles.textStyle: const TextStyle(
                fontFamily: 'Lato', fontSize: 28, fontWeight: FontWeight.bold),
          };
        },
      ),
      StyleRule(
        const BlockSelector("header2"),
        (doc, docNode) {
          return {
            Styles.textStyle: const TextStyle(
                fontFamily: 'Lato', fontSize: 24, fontWeight: FontWeight.bold),
          };
        },
      ),
      StyleRule(
        const BlockSelector("header3"),
        (doc, docNode) {
          return {
            Styles.textStyle: const TextStyle(
                fontFamily: 'Lato', fontSize: 20, fontWeight: FontWeight.bold),
          };
        },
      ),
      StyleRule(
        const BlockSelector("blockquote"),
        (doc, docNode) {
          return {
            Styles.textStyle: const TextStyle(
              fontFamily: 'Merriweather',
              fontStyle: FontStyle.italic,
              height: 1.4,
            )
          };
        },
      )
    ];
    return defaultStylesheet.copyWith(rules: defaultStylesheet.rules + myRules);
  }

  void _onDocumentChange(DocumentChangeLog changeLog) {
    widget.onChanged();
  }

  void _createEmptyDoc() {
    final document = MutableDocument(
      nodes: [
        ParagraphNode(id: '0', text: AttributedText('')),
      ],
    )..addListener(_onDocumentChange);

    _editor = createDefaultDocumentEditor(
      document: document,
      composer: _composer,
      isHistoryEnabled: _enableUndoRedo,
    );
  }
}
