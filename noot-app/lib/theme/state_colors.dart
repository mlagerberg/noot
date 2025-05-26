import 'package:flutter/material.dart';
import 'package:todo/models/models.dart';

/// Collections of colors used as an extension to the Theme,
/// so we can access the correct colors throughout the app
/// without if-elseing for dark or light theme.
class StateColors extends ThemeExtension<StateColors> {
  final Color background;
  final Color backgroundLighter;
  final Color backgroundDarker;
  final Color text;
  final Color dimmed;
  final Color icons;
  final Color nameTag;
  final Color url;
  final Color timestamp;
  final Color error;
  final Color warning;
  final Color ok;

  final Color taskOpenIcon;
  final Color taskOpenText;
  final Color taskDoneIcon;
  final Color taskDoneText;
  final Color taskRejectedIcon;
  final Color taskRejectedText;
  final Color taskImportantIcon;
  final Color taskImportantText;
  final Color taskUnderDiscussionIcon;
  final Color taskUnderDiscussionText;
  final Color taskInProgressIcon;
  final Color taskInProgressText;
  final Color separator;
  final Color date;

  late final Map<TaskState, Color> taskStateColors;
  late final Map<TaskState, Color> taskStateColorsText;
  late final Map<EntryType, Color> entryColors;

  StateColors(
      {required this.background,
      required this.backgroundLighter,
      required this.backgroundDarker,
      required this.text,
      required this.dimmed,
      required this.icons,
      required this.error,
      required this.warning,
      required this.ok,
      required this.nameTag,
      required this.url,
      required this.timestamp,
      required this.taskOpenIcon,
      required this.taskOpenText,
      required this.taskDoneIcon,
      required this.taskDoneText,
      required this.taskRejectedIcon,
      required this.taskRejectedText,
      required this.taskImportantIcon,
      required this.taskImportantText,
      required this.taskUnderDiscussionIcon,
      required this.taskUnderDiscussionText,
      required this.taskInProgressIcon,
      required this.taskInProgressText,
      required this.separator,
      required this.date}) {
    taskStateColors = {
      TaskState.open: taskOpenIcon,
      TaskState.done: taskDoneIcon,
      TaskState.rejected: taskRejectedIcon,
      TaskState.important: taskImportantIcon,
      TaskState.underDiscussion: taskUnderDiscussionIcon,
      TaskState.inProgress: taskInProgressIcon,
    };
    taskStateColorsText = {
      TaskState.open: taskOpenText,
      TaskState.done: taskDoneText,
      TaskState.rejected: taskRejectedText,
      TaskState.important: taskImportantText,
      TaskState.underDiscussion: taskUnderDiscussionText,
      TaskState.inProgress: taskInProgressText,
    };
    entryColors = {
      EntryType.task: taskDoneIcon,
      EntryType.subtask: taskDoneIcon,
      EntryType.date: date,
      EntryType.separator: separator,
      EntryType.title: taskImportantIcon,
      EntryType.text: text,
      EntryType.empty: taskDoneText
    };
  }

  Color taskStateColor(TaskState state) => taskStateColors[state]!;

  Color taskStateColorText(TaskState state) => taskStateColorsText[state]!;

  Color entryColor(EntryType type) => entryColors[type]!;

  @override
  ThemeExtension<StateColors> copyWith(
      {Color? background,
      Color? backgroundLighter,
      Color? backgroundDarker,
      Color? text,
      Color? icons,
      Color? dimmed,
      Color? nameTag,
      Color? url,
      Color? timestamp,
      Color? error,
      Color? warning,
      Color? ok,
      Color? taskOpenIcon,
      Color? taskOpenText,
      Color? taskDoneIcon,
      Color? taskDoneText,
      Color? taskRejectedIcon,
      Color? taskRejectedText,
      Color? taskImportantIcon,
      Color? taskImportantText,
      Color? taskUnderDiscussionIcon,
      Color? taskUnderDiscussionText,
      Color? taskInProgressIcon,
      Color? taskInProgressText,
      Color? separator,
      Color? date}) {
    return StateColors(
        background: background ?? this.background,
        backgroundLighter: backgroundLighter ?? this.backgroundLighter,
        backgroundDarker: backgroundDarker ?? this.backgroundDarker,
        text: text ?? this.text,
        icons: icons ?? this.icons,
        dimmed: dimmed ?? this.dimmed,
        nameTag: nameTag ?? this.nameTag,
        url: url ?? this.url,
        timestamp: timestamp ?? this.timestamp,
        error: error ?? this.error,
        warning: warning ?? this.warning,
        ok: ok ?? this.ok,
        taskOpenIcon: taskOpenIcon ?? this.taskOpenIcon,
        taskOpenText: taskOpenText ?? this.taskOpenText,
        taskDoneIcon: taskDoneIcon ?? this.taskDoneIcon,
        taskDoneText: taskDoneText ?? this.taskDoneText,
        taskRejectedIcon: taskRejectedIcon ?? this.taskRejectedIcon,
        taskRejectedText: taskRejectedText ?? this.taskRejectedText,
        taskImportantIcon: taskImportantIcon ?? this.taskImportantIcon,
        taskImportantText: taskImportantText ?? this.taskImportantText,
        taskUnderDiscussionIcon:
            taskUnderDiscussionIcon ?? this.taskUnderDiscussionIcon,
        taskUnderDiscussionText:
            taskUnderDiscussionText ?? this.taskUnderDiscussionText,
        taskInProgressIcon: taskInProgressIcon ?? this.taskInProgressIcon,
        taskInProgressText: taskInProgressText ?? this.taskInProgressText,
        separator: separator ?? this.separator,
        date: date ?? this.date);
  }

  @override
  ThemeExtension<StateColors> lerp(
      covariant ThemeExtension<StateColors>? other, double t) {
    if (other is! StateColors) {
      return this;
    }
    return StateColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundLighter:
          Color.lerp(backgroundLighter, other.backgroundLighter, t)!,
      backgroundDarker:
          Color.lerp(backgroundDarker, other.backgroundDarker, t)!,
      text: Color.lerp(text, other.text, t)!,
      icons: Color.lerp(icons, other.icons, t)!,
      dimmed: Color.lerp(dimmed, other.dimmed, t)!,
      nameTag: Color.lerp(nameTag, other.nameTag, t)!,
      url: Color.lerp(url, other.url, t)!,
      timestamp: Color.lerp(timestamp, other.timestamp, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      taskOpenIcon: Color.lerp(taskOpenIcon, other.taskOpenIcon, t)!,
      taskOpenText: Color.lerp(taskOpenText, other.taskOpenText, t)!,
      taskDoneIcon: Color.lerp(taskDoneIcon, other.taskDoneIcon, t)!,
      taskDoneText: Color.lerp(taskDoneText, other.taskDoneText, t)!,
      taskRejectedIcon:
          Color.lerp(taskRejectedIcon, other.taskRejectedIcon, t)!,
      taskRejectedText:
          Color.lerp(taskRejectedText, other.taskRejectedText, t)!,
      taskImportantIcon:
          Color.lerp(taskImportantIcon, other.taskImportantIcon, t)!,
      taskImportantText:
          Color.lerp(taskImportantText, other.taskImportantText, t)!,
      taskUnderDiscussionIcon: Color.lerp(
          taskUnderDiscussionIcon, other.taskUnderDiscussionIcon, t)!,
      taskUnderDiscussionText: Color.lerp(
          taskUnderDiscussionText, other.taskUnderDiscussionText, t)!,
      taskInProgressIcon:
          Color.lerp(taskInProgressIcon, other.taskInProgressIcon, t)!,
      taskInProgressText:
          Color.lerp(taskInProgressText, other.taskInProgressText, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      date: Color.lerp(date, other.date, t)!,
    );
  }
}
