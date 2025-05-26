import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/theme/theme.dart';

/// A centralized class to manage application preferences
/// with type-safe getters and setters
class PreferenceManager {
  final SharedPreferences _prefs;

  static final String defaultDateFormat = 'EEE d MMM';

  PreferenceManager(this._prefs);

  /// Last known status (open/collapsed) of the start screen.
  /// Used only in tablet layouts.
  bool get sidebarCollapsed => _prefs.getBool('sidebarCollapsed') ?? false;

  set sidebarCollapsed(bool value) => _prefs.setBool('sidebarCollapsed', value);

  /// Autosave files when navigating away.
  /// Not used, because there is no undo yet, or a way to discard changes.
  bool get autosave => _prefs.getBool('autosave') ?? false;

  set autosave(bool value) => _prefs.setBool('autosave', value);

  /// Default edit mode preference: TO-DO list or text
  bool get defaultModeText => _prefs.getBool('defaultMode') ?? false;

  set defaultModeText(bool value) => _prefs.setBool('defaultMode', value);

  /// Syntax preference: on or off (in text mode)
  bool get enableSyntax => _prefs.getBool('highlightSyntax') ?? false;

  set enableSyntax(bool value) => _prefs.setBool('highlightSyntax', value);

  /// Syntax preference: markdown or TO-DO
  bool get txtIsMarkdown => _prefs.getBool('txtIsMarkdown') ?? false;

  set txtIsMarkdown(bool value) => _prefs.setBool('txtIsMarkdown', value);

  /// Confirm discard preference
  bool get confirmDiscard => _prefs.getBool('confirmDiscard') ?? false;

  set confirmDiscard(bool value) => _prefs.setBool('confirmDiscard', value);

  /// Enable swipe gestures (in TO-DO mode)
  bool get enableSwipe => _prefs.getBool('enableSwipe') ?? true;

  set enableSwipe(bool value) => _prefs.setBool('enableSwipe', value);

  /// Date formatting format
  String get dateFormat => _prefs.getString('dateFormat') ?? defaultDateFormat;

  set dateFormat(String value) => _prefs.setString('dateFormat', value);

  /// Limit to txt and MD files when importing a folder
  bool get limitToTxtAndMD => _prefs.getBool('limitToTxtAndMD') ?? false;

  set limitToTxtAndMD(bool value) => _prefs.setBool('limitToTxtAndMD', value);

  /// Show hidden files when importing a folder.
  /// Only used when limitToTxtAndMD is false.
  bool get showHiddenFiles => _prefs.getBool('showHiddenFiles') ?? false;

  set showHiddenFiles(bool value) => _prefs.setBool('showHiddenFiles', value);

  /// Put recently opened files at the top
  bool get sortByOpened => _prefs.getBool('sortByOpened') ?? true;

  set sortByOpened(bool value) => _prefs.setBool('sortByOpened', value);

  /// Fix padding preference.
  /// Adds some padding to the top of the screen to make the caption bar does not
  /// overlap when using the app non-fullscreen on Android tablets in Desktop Mode.
  bool get fixPadding => _prefs.getBool('fixPadding') ?? false;

  set fixPadding(bool value) => _prefs.setBool('fixPadding', value);

  /// Dark theme id
  String get darkTheme =>
      _prefs.getString('darkTheme') ?? AppTheme.defaultDarkTheme;

  set darkTheme(String value) => _prefs.setString('darkTheme', value);

  /// Light theme id
  String get lightTheme =>
      _prefs.getString('lightTheme') ?? AppTheme.defaultLightTheme;

  set lightTheme(String value) => _prefs.setString('lightTheme', value);

  /// Theme. 0 = dark, 1 = light, 2 = auto
  ThemeMode get theme => ThemeMode.values[_prefs.getInt('theme') ?? 0];

  set theme(ThemeMode value) => _prefs.setInt('theme', value.index);

  /// Force bright mode in rich text editor.
  /// Added because the rich text editor (super-editor) does not support changing
  /// the caret color, making it invisible on a dark background.
  bool get forceBrightModeMarkdown =>
      _prefs.getBool('forceBrightModeMarkdown') ?? false;

  set forceBrightModeMarkdown(bool value) =>
      _prefs.setBool('forceBrightModeMarkdown', value);
}
