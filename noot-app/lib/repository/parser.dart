import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/models.dart';
import 'package:todo/theme/state_colors.dart';

/// A parser class for processing text content into a list of [Entry] objects.
///
/// Parses lines of text into structured [Entry] objects, which represent
/// tasks, subtasks, titles, and more. Identifies specific patterns like
/// @-mentions, time formats, and URLs.
class Parser {
  static final supportOldDateSyntax = true;

  static final RegExp nameRegExp = RegExp(r'@\w+');
  static final RegExp timeRegExp = RegExp(r'\b\d{1,2}:\d{2}\b');
  static final RegExp urlRegExp = RegExp(r'https?:\/\/\S+');

  /// Takes utf-8 content and returns the parsed list of [Entry] objects.
  List<Entry> parse(AppLocalizations locale, String content) {
    final lines = content.split('\n');
    final List<Entry> entries = [];
    Entry? lastTask;

    for (var line in lines) {
      final entry = _parseLine(locale, line, lastTask);
      if (entry != null) {
        entries.add(entry);
        if (entry.type == EntryType.task) {
          lastTask = entry;
        }
      }
    }

    // Add a first empty item if the file is blank
    if (entries.isEmpty) {
      entries.add(Entry.blank());
    }

    return entries;
  }

  /// Parses a single line of text into an [Entry] object.
  Entry? _parseLine(AppLocalizations locale, String line, Entry? lastTask) {
    if (line.startsWith('=== ') && line.endsWith(' ===')) {
      return Entry(
          type: EntryType.title,
          originalPrefix: '===',
          content: line.substring(3, line.length - 4).trim());
    } else if (line.startsWith('#')) {
      final titleStart = max(0, line.indexOf(' '));
      return Entry(
          type: EntryType.title,
          originalPrefix: line.substring(0, titleStart).trim(),
          content: line.substring(titleStart).trim());
    } else if (line.startsWith('---') || line.startsWith('===')) {
      return Entry(
        type: EntryType.separator,
        content: line.trim(),
      );
    } else if (line.startsWith('    ') || line.startsWith('\t')) {
      return _parseSubtask(line, lastTask);
    } else if (line.startsWith('[')) {
      return _parseTask(line);
    } else if (line.startsWith('%')) {
      return Entry(
        type: EntryType.date,
        originalPrefix: '%',
        content: line.substring(1).trim(),
      );
    } else if (supportOldDateSyntax &&
        _startsWithAny(line, [
          locale.abbr_monday,
          locale.abbr_tuesday,
          locale.abbr_wednesday,
          locale.abbr_thursday,
          locale.abbr_friday,
          locale.abbr_saturday,
          locale.abbr_sunday,
          locale.abbr_monday_2,
          locale.abbr_tuesday_2,
          locale.abbr_wednesday_2,
          locale.abbr_thursday_2,
          locale.abbr_friday_2,
          locale.abbr_saturday_2,
          locale.abbr_sunday_2,
        ])) {
      return Entry(
        type: EntryType.date,
        content: line.trim(),
      );
    } else {
      return Entry(
        type: EntryType.text,
        content: line,
      );
    }
  }

  bool _startsWithAny(String line, List<String> prefixes) {
    for (var prefix in prefixes) {
      if (line.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }

  /// Parses a line into a Task Entry.
  ///
  /// Returns an [Entry] object of type [EntryType.task] with the detected [TaskState].
  /// If no valid marker is found, the task state remains null.
  Entry _parseTask(String line) {
    TaskState? state;

    if (line.startsWith('[ ]')) {
      state = TaskState.open;
      line = line.substring(3).trim();
    } else if (line.startsWith('[v]')) {
      state = TaskState.done;
      line = line.substring(3).trim();
    } else if (line.startsWith('[x]')) {
      state = TaskState.rejected;
      line = line.substring(3).trim();
    } else if (line.startsWith('[!]')) {
      state = TaskState.important;
      line = line.substring(3).trim();
    } else if (line.startsWith('[?]')) {
      state = TaskState.underDiscussion;
      line = line.substring(3).trim();
    } else if (line.startsWith('[~]')) {
      state = TaskState.inProgress;
      line = line.substring(3).trim();
    }

    return Entry(
      type: EntryType.task,
      state: state,
      content: line,
    );
  }

  /// Parses a single line into an Entry.
  ///
  /// The line is inspected for title, separator, date, task, and subtask
  /// markers. If none of those markers are found, the line is considered a
  /// plain text entry.
  ///
  /// [lastTask] refers to the last read root-level task (which will be the
  /// parent for this subtask)
  Entry _parseSubtask(String line, Entry? lastTask) {
    TaskState? state;
    bool tabs = line.startsWith('\t');
    line = line.trim();

    if (line.startsWith('v ')) {
      state = TaskState.done;
      line = line.substring(1).trim();
    } else if (line.startsWith('x ')) {
      state = TaskState.rejected;
      line = line.substring(1).trim();
    } else if (line.startsWith('- ')) {
      state = TaskState.open;
      line = line.substring(1).trim();
    } else if (line.startsWith('! ')) {
      state = TaskState.important;
      line = line.substring(1).trim();
    } else if (line.startsWith('? ')) {
      state = TaskState.underDiscussion;
      line = line.substring(1).trim();
    } else if (line.startsWith('~ ')) {
      state = TaskState.inProgress;
      line = line.substring(1).trim();
    } else {
      // None of these symbols? It is Text after all
      return Entry(
        type: EntryType.text,
        content: line,
      );
    }

    final result = Entry(
      type: EntryType.subtask,
      state: state,
      originalPrefix: tabs ? '\t' : '    ',
      content: line,
      parentTask: lastTask,
    );
    result.refreshDisplayState();
    return result;
  }

  /// Highlights @-mentions, #tags, and URLs in [text].
  static Widget highlightText(
      ThemeData theme, Entry entry, Color defaultColor) {
    final text = entry.content;

    // Don't highlight if task is done
    if (entry.isDone() || entry.parentTask?.isDone() == true) {
      return Text(entry.content,
          style: theme.textTheme.bodyMedium?.copyWith(color: defaultColor));
    }

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    // Combine all regex patterns
    final RegExp combinedRegExp = RegExp(
      '(${nameRegExp.pattern})|(${timeRegExp.pattern})|(${urlRegExp.pattern})',
    );

    final matches = combinedRegExp.allMatches(text);

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: theme.textTheme.bodyMedium?.copyWith(color: defaultColor),
        ));
      }

      final matchedText = match.group(0)!;

      if (urlRegExp.hasMatch(matchedText)) {
        spans.add(TextSpan(
          text: matchedText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.extension<StateColors>()?.url,
            decoration: TextDecoration.underline,
          ),
        ));
      } else if (nameRegExp.hasMatch(matchedText)) {
        spans.add(TextSpan(
          text: matchedText,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.extension<StateColors>()?.nameTag),
        ));
      } else if (timeRegExp.hasMatch(matchedText)) {
        spans.add(TextSpan(
          text: matchedText,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.extension<StateColors>()?.timestamp),
        ));
      }

      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: theme.textTheme.bodyMedium?.copyWith(color: defaultColor),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
