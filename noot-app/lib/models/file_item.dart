import 'package:flutter/cupertino.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/item.dart';

enum EditMode { todo, text, markdown }

/// Represents a file item with properties such as scroll positions, text selection,
/// edit mode, and last opened time.
///
/// Unfortunately the rich text editor does not support setting the
/// scroll position or selection, so this is not supported for EditMode.markdown.
///
/// Properties:
/// - `scrollPositionTodo`: The scroll position when in 'To Do' edit mode.
/// - `scrollPositionText`: The scroll position when in 'Text' edit mode.
/// - `selectionStart`: The start position of the text selection, or the caret position.
/// - `selectionEnd`: The end position of the text selection, if any, otherwise equal to `selectionStart`.
/// - `editMode`: The current editing mode of the file, either 'To Do' or 'Text'.
/// - `lastOpenedTime`: The last time the file was opened, stored as a timestamp.
class FileItem extends Item {
  double scrollPositionTodo;
  double scrollPositionText;
  int selectionStart;
  int selectionEnd;
  EditMode editMode = EditMode.todo;
  int lastOpenedTime = -1;

  FileItem(
      {required super.title,
      required super.uri,
      super.parentUri,
      super.isPinned = false,
      this.scrollPositionTodo = 0,
      this.scrollPositionText = 0,
      this.selectionStart = 0,
      this.selectionEnd = 0,
      this.lastOpenedTime = -1,
      this.editMode = EditMode.todo}) {
    if (lastOpenedTime == -1) {
      resetLastOpened();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'title': title,
        'uri': uri.toString(),
        'scrollPosition': scrollPositionTodo,
        'scrollPosition_Text': scrollPositionText,
        'selectionStart': selectionStart,
        'selectionEnd': selectionEnd,
        'lastOpenedTime': lastOpenedTime,
        'isPinned': isPinned,
        'editMode': editMode.name,
        'isFolder': false,
      };

  factory FileItem.fromJson(Map<String, dynamic> json, Uri? parentUri) {
    final uri = Uri.parse(json['uri']);
    try {
      return FileItem(
        title: json['title'] ?? Item.titleFromUri(uri),
        uri: uri,
        scrollPositionTodo: json['scrollPosition'] ?? 0.0,
        scrollPositionText: json['scrollPosition_Text'] ?? 0.0,
        selectionStart: json['selectionStart'] ?? 0,
        selectionEnd: json['selectionEnd'] ?? 0,
        lastOpenedTime: json['lastOpenedTime'] ?? -1,
        isPinned: json['isPinned'] ?? false,
        editMode: EditMode.values.byName(json['editMode'] ?? 'todo'),
        parentUri: parentUri,
      );
    } catch (e) {
      debugPrint(e.toString());

      return FileItem(
          title: uri.pathSegments.last.split('/').last,
          uri: uri,
          scrollPositionTodo: 0.0,
          scrollPositionText: 0.0,
          selectionStart: 0,
          selectionEnd: 0,
          lastOpenedTime: -1,
          isPinned: false,
          editMode: EditMode.todo);
    }
  }

  /// Resets the `lastOpenedTime` to the current time.
  void resetLastOpened() {
    if (DateTime.now().millisecondsSinceEpoch != lastOpenedTime) {
      lastOpenedTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// Returns the `lastOpenedTime` as a human readable string.
  String prettyDate(AppLocalizations locale) {
    if (this.lastOpenedTime <= 0) return '';

    final now = DateTime.now();
    final lastOpenedTime =
        DateTime.fromMillisecondsSinceEpoch(this.lastOpenedTime);
    final difference = now.difference(lastOpenedTime);

    if (difference.inDays > 365) {
      return DateFormat('d MMM yyyy').format(lastOpenedTime);
    } else if (difference.inDays > 7) {
      return DateFormat('d MMM').format(lastOpenedTime);
    } else if (difference.inDays > 1) {
      return DateFormat('EEEE d MMM').format(lastOpenedTime);
    } else if (difference.inDays == 1) {
      return locale.date_yesterday;
    } else if (difference.inHours >= 2) {
      return locale.date_hours_ago(difference.inHours);
    } else if (difference.inHours >= 1) {
      return locale.date_an_hour_ago;
    } else if (difference.inMinutes >= 2) {
      return locale.date_minutes_ago(difference.inMinutes);
    } else if (difference.inMinutes >= 1) {
      return locale.date_a_minute_ago;
    } else {
      return locale.date_just_now;
    }
  }

  double getScrollPosition() {
    if (editMode == EditMode.todo) {
      return scrollPositionTodo;
    } else {
      return scrollPositionText;
    }
  }

  List<int> getSelection() {
    if (editMode == EditMode.todo) {
      return [0, 0];
    } else {
      return [selectionStart, selectionEnd];
    }
  }
}
