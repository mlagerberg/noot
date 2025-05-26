import 'package:flutter/material.dart';
import 'package:todo/models/models.dart';
import 'package:todo/theme/state_colors.dart';

class AppTheme {

  // Get the brightness.
  static bool isDark(ThemeMode themeMode, BuildContext context) {
    if (themeMode == ThemeMode.system) {
      var brightness = View.of(context).platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  static const String fontFamily = 'Monospace';

  // Giving dark mode a proper name because we might add more
  // color schemes in the future.
  static const String defaultDarkTheme = 'monokai';
  static const String defaultLightTheme = 'light';

  static const Color backgroundDarker = Color(0xFF1F201B);
  static const Color background = Color(0xFF272822);
  static const Color backgroundLighter = Color(0xFF35362E);
  static const Color text = Color(0xFFF8F8F2);

  static const Color bright_backgroundDarker = Color(0xFFDCDCD6);
  static const Color bright_background = Color(0xFFEFEFE9);
  static const Color bright_backgroundLighter = Color(0xFFF8F8F2);
  static const Color bright_text = Color(0xFF1E1D1D);

  // Dark mode base colors
  static const Color yellow = Color(0xFFE6DB74);
  static const Color green = Color(0xFFA6E22E);
  static const Color red = Color(0xFFF92672);
  static const Color orange = Color(0xFFFD971F);
  static const Color cyan = Color(0xFF66D9EF);
  static const Color dimmed = Color(0xFF75715E);
  static const Color purple = Color(0xFFAE81FF);

  // Light mode base colors
  static const Color bright_yellow = Color(0xFF816E38);
  static const Color bright_green = Color(0xFF46A111);
  static const Color bright_red = Color(0xFFD20C0C);
  static const Color bright_orange = Color(0xFFDA7603);
  static const Color bright_cyan = Color(0xFF057AB8);
  static const Color bright_dimmed = Color(0xFF959187);
  static const Color bright_purple = Color(0xFF5D1BD2);

  static final Map<TaskState, IconData> taskStateIcons = {
    TaskState.open: Icons.radio_button_unchecked,
    TaskState.done: Icons.check_circle_rounded,
    TaskState.rejected: Icons.cancel_rounded,
    TaskState.important: Icons.error_rounded,
    TaskState.underDiscussion: Icons.help_rounded,
    TaskState.inProgress: Icons.sync_rounded,
  };

  static const TextStyle entryTextStyle = TextStyle(
    color: text,
    fontFamily: fontFamily,
    fontSize: 16.0,
  );
  static const TextStyle smallTextStyle = TextStyle(
    color: dimmed,
    fontFamily: fontFamily,
    fontSize: 12.0,
  );
  static const TextStyle titleTextStyle = TextStyle(
    color: text,
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  static final ThemeData themeData = ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      StateColors(
        background: background,
        backgroundLighter: backgroundLighter,
        backgroundDarker: backgroundDarker,
        text: text,
        icons: orange,
        dimmed: dimmed,
        nameTag: orange,
        url: cyan,
        timestamp: cyan,
        error: red,
        warning: orange,
        ok: green,
        taskOpenIcon: dimmed,
        taskOpenText: text,
        taskDoneIcon: green,
        taskDoneText: dimmed,
        taskRejectedIcon: red,
        taskRejectedText: dimmed,
        taskImportantIcon: red,
        taskImportantText: red,
        taskUnderDiscussionIcon: yellow,
        taskUnderDiscussionText: yellow,
        taskInProgressIcon: yellow,
        taskInProgressText: yellow,
        separator: green,
        date: purple,
      )
    ],

    brightness: Brightness.dark,
    dialogBackgroundColor: background,
    disabledColor: dimmed,
    dividerColor: red,
    hintColor: dimmed,
    indicatorColor: green,
    primaryColor: background,
    scaffoldBackgroundColor: background,
    splashColor: background,

    appBarTheme: const AppBarTheme(
      color: background,
      titleTextStyle: titleTextStyle,
      iconTheme: IconThemeData(
        color: orange,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: entryTextStyle.copyWith(fontSize: 18.0),
      bodyMedium: entryTextStyle,
      bodySmall: smallTextStyle,
      headlineMedium: titleTextStyle,
      // Date / datetextStyle
      labelMedium:
          TextStyle(color: purple, fontFamily: fontFamily, fontSize: 18.0),
      titleMedium: titleTextStyle.copyWith(color: orange),
      displayMedium: entryTextStyle.copyWith(color: orange),
    ),
    iconTheme: const IconThemeData(
      color: orange,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      backgroundColor: orange,
      foregroundColor: background,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      textStyle: entryTextStyle.copyWith(color: background),
    )),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      foregroundColor: orange,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      textStyle: entryTextStyle.copyWith(color: orange),
    )),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: orange),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: text,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      labelStyle: entryTextStyle,
      hintStyle: entryTextStyle.copyWith(color: dimmed),
    ),
    popupMenuTheme: const PopupMenuThemeData(
        color: backgroundLighter,
        textStyle: entryTextStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: dimmed),
        )),
    menuTheme: MenuThemeData(
        style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(backgroundLighter),
    )),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: entryTextStyle,
      menuStyle: MenuStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        backgroundColor: WidgetStateColor.resolveWith(
          (Set<WidgetState> states) {
            return backgroundLighter;
          },
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: dimmed),
        )),
      ),
    ),
    dialogTheme: const DialogThemeData(
        backgroundColor: background,
        titleTextStyle: titleTextStyle,
        contentTextStyle: entryTextStyle),
    snackBarTheme: const SnackBarThemeData(
        actionTextColor: orange,
        backgroundColor: backgroundLighter,
        contentTextStyle: entryTextStyle,
        elevation: 4),
  );

  // ======================================

  static var lightThemeData = ThemeData(
    extensions: <ThemeExtension<dynamic>>[
      StateColors(
        background: bright_background,
        backgroundLighter: bright_backgroundLighter,
        backgroundDarker: bright_backgroundDarker,
        text: bright_text,
        icons: bright_text,
        dimmed: bright_dimmed,
        nameTag: orange,
        url: bright_cyan,
        timestamp: bright_cyan,
        error: red,
        warning: bright_orange,
        ok: bright_green,
        taskOpenIcon: bright_dimmed,
        taskOpenText: bright_text,
        taskDoneIcon: bright_green,
        taskDoneText: bright_dimmed,
        taskRejectedIcon: bright_red,
        taskRejectedText: bright_dimmed,
        taskImportantIcon: bright_red,
        taskImportantText: bright_red,
        taskUnderDiscussionIcon: bright_yellow,
        taskUnderDiscussionText: bright_yellow,
        taskInProgressIcon: bright_yellow,
        taskInProgressText: bright_yellow,
        separator: bright_green,
        date: bright_purple,
      )
    ],

    brightness: Brightness.light,
    dialogBackgroundColor: bright_background,
    disabledColor: bright_dimmed,
    dividerColor: bright_red,
    hintColor: bright_dimmed,
    indicatorColor: bright_green,
    primaryColor: bright_background,
    scaffoldBackgroundColor: bright_background,
    splashColor: bright_background,

    appBarTheme: AppBarTheme(
      color: bright_background,
      titleTextStyle: titleTextStyle.copyWith(color: bright_text),
      iconTheme: IconThemeData(
        color: bright_orange,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: entryTextStyle.copyWith(color: bright_text, fontSize: 18.0),
      bodyMedium: entryTextStyle.copyWith(color: bright_text),
      bodySmall: smallTextStyle.copyWith(color: bright_dimmed),
      headlineMedium: titleTextStyle.copyWith(color: bright_text),
      labelMedium: TextStyle(
          color: bright_purple, fontFamily: fontFamily, fontSize: 18.0),
      titleMedium: titleTextStyle.copyWith(color: bright_purple),
      displayMedium: entryTextStyle.copyWith(color: bright_purple),
    ),
    iconTheme: const IconThemeData(
      color: bright_orange,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      backgroundColor: bright_orange,
      foregroundColor: bright_background,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      textStyle: entryTextStyle.copyWith(color: bright_background),
    )),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      foregroundColor: bright_orange,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      textStyle: entryTextStyle.copyWith(color: bright_orange),
    )),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: bright_orange),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bright_text,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      labelStyle: entryTextStyle.copyWith(color: bright_text),
      hintStyle: entryTextStyle.copyWith(color: bright_dimmed),
    ),
    popupMenuTheme: PopupMenuThemeData(
        color: bright_backgroundLighter,
        textStyle: entryTextStyle.copyWith(color: bright_text),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: bright_dimmed),
        )),
    menuTheme: MenuThemeData(
        style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(backgroundLighter),
    )),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: entryTextStyle.copyWith(color: bright_text),
      menuStyle: MenuStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        backgroundColor: WidgetStateColor.resolveWith(
          (Set<WidgetState> states) {
            return bright_backgroundLighter;
          },
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
            const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          side: BorderSide(color: bright_dimmed),
        )),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
        actionTextColor: bright_red,
        backgroundColor: bright_backgroundLighter,
        contentTextStyle: entryTextStyle.copyWith(color: bright_text),
        elevation: 4),
  );
}
