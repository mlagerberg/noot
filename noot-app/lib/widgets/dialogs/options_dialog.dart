import 'package:flutter/material.dart';

/// An generic selection dialog widget. Can take a list of values to display,
/// with one being selected by default. Returns the index of the selected value.
class OptionDialog extends StatelessWidget {
  final int current;
  final String title;
  final List<String> values;

  const OptionDialog(
      {super.key,
      required this.title,
      required this.current,
      required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SimpleDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(title, style: theme.textTheme.titleMedium),
      children: <Widget>[
        ...values.expand((value) => [
              SimpleDialogOption(
                onPressed: () {
                  int index = values.indexOf(value);
                  Navigator.pop(context, index);
                },
                child: Text(value),
              ),
            ])
      ],
    );
  }
}
