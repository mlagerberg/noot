import 'package:flutter/material.dart';

/// Button in the settings that allows the user to toggle a setting on or off.
class ToggleButton extends StatelessWidget {
  const ToggleButton(
      {super.key,
      required this.title,
      this.enabled = true,
      this.description,
      required this.value,
      required this.onSettingChanged});

  final String title;
  final bool enabled;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onSettingChanged;

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
      trailing: Switch(
        value: value,
        onChanged: enabled ? onSettingChanged : null,
      ),
    );
  }
}
