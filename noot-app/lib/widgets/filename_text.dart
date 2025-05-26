import 'package:flutter/material.dart';

/// A Text widget that dims the extension of a filename
class FileNameText extends StatelessWidget {
  final String fileName;
  final TextStyle? style;
  final TextStyle? extensionStyle;

  const FileNameText({
    super.key,
    required this.fileName,
    this.style,
    this.extensionStyle,
  });

  @override
  Widget build(BuildContext context) {
    int dotIndex = fileName.indexOf('.');
    String name = dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
    String extension = dotIndex != -1 ? fileName.substring(dotIndex) : '';
    final theme = Theme.of(context);

    return RichText(
      overflow: TextOverflow.fade,
      maxLines: 1,
      softWrap: false,
      text: TextSpan(
        children: [
          TextSpan(
            text: name,
            style: style ?? theme.textTheme.bodyLarge,
          ),
          TextSpan(
            text: extension,
            style: extensionStyle ??
                theme.textTheme.bodySmall?.copyWith(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
