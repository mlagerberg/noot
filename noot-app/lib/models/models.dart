enum EntryType { title, task, subtask, date, text, empty, separator }

enum TaskState { open, done, rejected, inProgress, important, underDiscussion }

/// Represents a single entry in a To-do/Noot file.
///
/// Properties:
/// - `type`: The type of the entry (e.g. title, task, subtask, date, text).
/// - `state`: The state of the task (e.g. open, done, rejected).
/// - `displayState`: The state of the task, taking into account the state of its parent task.
/// - `originalPrefix`: When parsing removes part of the content, we store the original prefix to be able to put it back when formatting to file.
/// - `content`: The text content of the entry.
/// - `parentTask`: The parent task of this entry, if it is a subtask.
class Entry {
  EntryType type;
  TaskState? state;
  TaskState? displayState;
  String? originalPrefix;
  String content;
  Entry? parentTask;

  Entry(
      {required this.type,
      this.state,
      this.displayState,
      this.originalPrefix,
      required this.content,
      this.parentTask});

  static Entry blank() {
    return Entry(type: EntryType.task, state: TaskState.open, content: '');
  }

  /// Both tasks and subtasks are considered tasks, and can be ticked off.
  bool isTask() {
    return type == EntryType.task || type == EntryType.subtask;
  }

  /// Tasks are marked Done when they are done or rejected.
  bool isDone() {
    return isTask() && (state == TaskState.done || state == TaskState.rejected);
  }

  /// Updates the way the state is displayed, based on the parent task.
  /// This helps if a task is not completed (for example), but should be
  /// displayed as such because its parent task is completed.
  void refreshDisplayState() {
    displayState = null;
    if (parentTask == null) {
      return;
    }
    if (state == TaskState.done || state == TaskState.rejected) {
      displayState = state;
    } else {
      if (parentTask!.isDone() == true) {
        displayState = TaskState.done;
      } else if (parentTask!.state == TaskState.inProgress ||
          parentTask!.state == TaskState.underDiscussion ||
          parentTask!.state == TaskState.important) {
        displayState = parentTask!.state;
      }
    }
  }
  /// Creates an clone Entry object from an existing [entry].
  static Entry from(Entry entry) {
    final newEntry = Entry(
        type: entry.type,
        state: entry.state,
        displayState: entry.displayState,
        originalPrefix: entry.originalPrefix,
        content: entry.content,
        parentTask: entry.parentTask);
    newEntry.refreshDisplayState();
    return newEntry;
  }
}
