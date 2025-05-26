import 'package:flutter/material.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/models/models.dart';
import 'package:todo/theme/state_colors.dart';
import 'package:todo/theme/theme.dart';
import 'package:todo/utils/entry_utils.dart';
import 'package:todo/utils/ui_utils.dart';
import 'package:todo/widgets/datepicker_button.dart';

/// A dialog for editing a To-do entry.
/// Contains text edit field (in case the entry type supports text),
/// a dropdown to pick the type of entry, and possible a date picker
class EntryEditDialog extends StatefulWidget {
  final Entry entry;
  final ValueChanged<Entry> onSave;

  const EntryEditDialog({
    super.key,
    required this.entry,
    required this.onSave,
  });

  @override
  EntryEditDialogState createState() => EntryEditDialogState();
}

class EntryEditDialogState extends State<EntryEditDialog> {
  late TextEditingController _controller;
  late EntryType _selectedType;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.content);
    _selectedType = widget.entry.type;

    // Request focus after the dialog is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      insetPadding:
          EdgeInsets.symmetric(horizontal: isTablet(context) ? 100 : 32),
      content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Entry type dropdown
              DropdownButton<EntryType>(
                value: _selectedType,
                style: theme.textTheme.bodyMedium,
                dropdownColor:
                    theme.extension<StateColors>()!.backgroundLighter,
                borderRadius: BorderRadius.circular(16.0),
                underline: const SizedBox(),
                isExpanded: true,
                onChanged: (EntryType? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
                items: EntryType.values
                    .map<DropdownMenuItem<EntryType>>((EntryType type) {
                  return DropdownMenuItem<EntryType>(
                    value: type,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EntryUtils.buildEntryTypeIcon(theme, type),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Text(
                              EntryUtils.getTypeName(locale, type),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              // No text field for separators and empty lines
              if (_selectedType != EntryType.separator &&
                  _selectedType != EntryType.empty)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (_selectedType == EntryType.date)
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          color: AppTheme.lightThemeData
                              .extension<StateColors>()!
                              .backgroundLighter,
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        child: DatePickerButton(
                            content: _controller.text,
                            onDatePicked: _onDatePicked)),

                  // Some padding next to the date picker button
                  if (_selectedType == EntryType.date) SizedBox(width: 4),

                  Expanded(
                      child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: AppTheme.lightThemeData.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: locale.enter_new_content,
                      fillColor: AppTheme.lightThemeData
                          .extension<StateColors>()!
                          .backgroundLighter,
                    ),
                    maxLines: _selectedType == EntryType.text ? 8 : 1,
                    minLines: _selectedType == EntryType.text ? 6 : 1,
                    onSubmitted: (value) {
                      // Value is entered text after ENTER press
                      if (_selectedType != EntryType.text) {
                        _onDone();
                      }
                    },
                    textInputAction: _selectedType == EntryType.text
                        ? TextInputAction.newline
                        : TextInputAction.done,
                  ))
                ]),
            ],
          )),
      actions: <Widget>[
        // Cancel without saving changes
        TextButton(
          child: Text(locale.cancel, style: theme.textTheme.bodyMedium),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        // Finish and save.
        TextButton(
          onPressed: _onDone,
          child: Text(locale.save,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.extension<StateColors>()?.ok)),
        ),
      ],
    );
  }

  /// Performs a cleanup on the adjusted data, closes the dialog, and returns
  /// to the caller with the updated entry.
  void _onDone() {
    // Check for automatic conversions. E.g. text/title/task/date with empty
    // content becomes an empty line entry.
    // Text content starting with a # becomes title,
    // and text content starting with a % becomes a date,
    // and --- becomes a separator.
    final isConvertibleType = [
      EntryType.text,
      EntryType.title,
      EntryType.date,
      EntryType.task
    ].contains(_selectedType);
    var content = _controller.text;
    if (isConvertibleType) {
      if (content.isEmpty) {
        _selectedType = EntryType.empty;
      } else if (content.startsWith('# ')) {
        _selectedType = EntryType.title;
        content = content.substring(2);
      } else if (content.startsWith('% ')) {
        _selectedType = EntryType.date;
        content = content.substring(2);
      } else if (content.trim() == '---' || content.trim() == '===') {
        _selectedType = EntryType.separator;
        content = content.substring(3);
      }
    }

    final Entry updatedEntry = Entry(
      type: _selectedType == EntryType.empty ? EntryType.text : _selectedType,
      content: content,
      state: widget.entry.state,
      parentTask: widget.entry.parentTask,
    );
    // Make sure the state is set
    if (updatedEntry.isTask() && updatedEntry.state == null) {
      updatedEntry.state = TaskState.open;
    }
    // Return with the new entry
    Navigator.of(context).pop();
    widget.onSave(updatedEntry);
  }

  /// Updates the text field with the picked date
  void _onDatePicked(String dateStr, String? label) {
    if (label == null) {
      _controller.text = dateStr;
    } else {
      _controller.text = "$dateStr - $label";
    }
  }
}
