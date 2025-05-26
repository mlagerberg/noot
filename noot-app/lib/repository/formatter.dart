import 'package:todo/models/models.dart';

/// Formats the Entries back to text when writing to a file.
class Formatter {

  String entryToString(Entry entry) {
    String prefix = '';
    String suffix = '';
    if (entry.type == EntryType.task) {
      switch (entry.state) {
        case TaskState.open:
          prefix = '[ ] ';
          break;
        case TaskState.done:
          prefix = '[v] ';
          break;
        case TaskState.rejected:
          prefix = '[x] ';
          break;
        case TaskState.important:
          prefix = '[!] ';
          break;
        case TaskState.underDiscussion:
          prefix = '[?] ';
          break;
        case TaskState.inProgress:
          prefix = '[~] ';
          break;
        default:
          prefix = '';
      }
    } else if (entry.type == EntryType.subtask) {
      switch (entry.state) {
        case TaskState.open:
          prefix = '- ';
          break;
        case TaskState.done:
          prefix = 'v ';
          break;
        case TaskState.rejected:
          prefix = 'x ';
          break;
        case TaskState.important:
          prefix = '! ';
          break;
        case TaskState.underDiscussion:
          prefix = '? ';
          break;
        case TaskState.inProgress:
          prefix = '~ ';
          break;
        default:
          prefix = '';
      }
      // Add indentation for subtasks
      if (entry.originalPrefix == null) {
        prefix = '    $prefix';
      } else {
        prefix = '${entry.originalPrefix}$prefix';
      }
    } else if (entry.type == EntryType.date) {
      prefix = '% ';
    } else if (entry.type == EntryType.title) {
      if (entry.originalPrefix == null) {
        prefix = '# ';
      } else if (entry.originalPrefix == '===') {
        prefix = '${entry.originalPrefix} ';
        suffix = ' ===';
      } else {
        prefix = '${entry.originalPrefix} ';
      }
    } else if (entry.type == EntryType.separator) {
      prefix = '';
      if (entry.content.trim().isEmpty) {
        return '---';
      }
    }
    return prefix + entry.content + suffix;
  }
}
