import 'package:flutter/material.dart';
import 'package:todo/widgets/dialogs/options_dialog.dart';

/// Entry in the settings that shows a button. When the button is pressed,
/// a dialog is shown that allows the user to change the setting.
class OptionButton extends StatelessWidget {

  const OptionButton(
      {super.key,
      required this.title,
      this.enabled = true,
      this.description,
      required this.value,
      required this.values,
      required this.onSettingChanged});

  final String title;
  final bool enabled;
  final String? description;
  final int value;
  final List<String> values;
  final ValueChanged<int>? onSettingChanged;

  void _onTap(BuildContext context) async {
    if (context.mounted && onSettingChanged != null) {
      final newValue = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return OptionDialog(title: title, current: value, values: values);
        },
      );
      if (newValue != null && value != newValue) {
        onSettingChanged!(newValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ListTile(
        title: Text(
          title,
          style: theme.bodyMedium,
        ),
        subtitle: description != null
            ? Text(description!, style: theme.bodySmall)
            : null,
        trailing: Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: InkWell(
              onTap: enabled == false ? null : () => _onTap(context),
              child: Text(values[value],
                  style: theme.displayMedium
              )),
        ));
  }
}
