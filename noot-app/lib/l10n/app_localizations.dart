import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Noot. (beta)'**
  String get app_name;

  /// No description provided for @app_name_short.
  ///
  /// In en, this message translates to:
  /// **'Noot.'**
  String get app_name_short;

  /// No description provided for @app_name_shorter.
  ///
  /// In en, this message translates to:
  /// **'Noot'**
  String get app_name_shorter;

  /// No description provided for @kofi_url.
  ///
  /// In en, this message translates to:
  /// **'https://ko-fi.com/mathijsl'**
  String get kofi_url;

  /// No description provided for @kofi_name.
  ///
  /// In en, this message translates to:
  /// **'mathijsl'**
  String get kofi_name;

  /// No description provided for @thank_you.
  ///
  /// In en, this message translates to:
  /// **'Thank you! You rock!'**
  String get thank_you;

  /// No description provided for @settings_intro.
  ///
  /// In en, this message translates to:
  /// **'This app is an editor text files, markdown, and for its own nameless to-do format. It is completely offline, has no cloud, and relies on your own Dropbox, Syncthing, rsync or other sync solution to work. It is fully compatible with plain text editors.\n\nCurrently in BETA, but there are plans to open source soon.\n\nCreated by Mathijs Lagerberg // mlagerberg.com\n\n'**
  String get settings_intro;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'This app does not collect any data, and therefore has no privacy policy.'**
  String get settings_privacy;

  /// No description provided for @settings_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get settings_website;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'https://mlagerberg.com/noot/'**
  String get website;

  /// No description provided for @settings_github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get settings_github;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'https://github.com/mlagerberg/'**
  String get github;

  /// No description provided for @settings_feedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settings_feedback;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'noot@mlagerberg.com'**
  String get email;

  /// No description provided for @feedback_subject.
  ///
  /// In en, this message translates to:
  /// **'Feedback on Noot app '**
  String get feedback_subject;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @date_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get date_yesterday;

  /// No description provided for @date_hours_ago.
  ///
  /// In en, this message translates to:
  /// **'{h} hours ago'**
  String date_hours_ago(Object h);

  /// No description provided for @date_an_hour_ago.
  ///
  /// In en, this message translates to:
  /// **'An hour ago'**
  String get date_an_hour_ago;

  /// No description provided for @date_minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'{m} minutes ago'**
  String date_minutes_ago(Object m);

  /// No description provided for @date_a_minute_ago.
  ///
  /// In en, this message translates to:
  /// **'A minute ago'**
  String get date_a_minute_ago;

  /// No description provided for @date_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get date_just_now;

  /// No description provided for @abbr_monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get abbr_monday;

  /// No description provided for @abbr_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get abbr_tuesday;

  /// No description provided for @abbr_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get abbr_wednesday;

  /// No description provided for @abbr_thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get abbr_thursday;

  /// No description provided for @abbr_friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get abbr_friday;

  /// No description provided for @abbr_saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get abbr_saturday;

  /// No description provided for @abbr_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get abbr_sunday;

  /// No description provided for @abbr_monday_2.
  ///
  /// In en, this message translates to:
  /// **'ma'**
  String get abbr_monday_2;

  /// No description provided for @abbr_tuesday_2.
  ///
  /// In en, this message translates to:
  /// **'di'**
  String get abbr_tuesday_2;

  /// No description provided for @abbr_wednesday_2.
  ///
  /// In en, this message translates to:
  /// **'wo'**
  String get abbr_wednesday_2;

  /// No description provided for @abbr_thursday_2.
  ///
  /// In en, this message translates to:
  /// **'do'**
  String get abbr_thursday_2;

  /// No description provided for @abbr_friday_2.
  ///
  /// In en, this message translates to:
  /// **'vr'**
  String get abbr_friday_2;

  /// No description provided for @abbr_saturday_2.
  ///
  /// In en, this message translates to:
  /// **'za'**
  String get abbr_saturday_2;

  /// No description provided for @abbr_sunday_2.
  ///
  /// In en, this message translates to:
  /// **'zo'**
  String get abbr_sunday_2;

  /// No description provided for @file_saved.
  ///
  /// In en, this message translates to:
  /// **'File saved'**
  String get file_saved;

  /// No description provided for @file_write_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to write to file'**
  String get file_write_failed;

  /// No description provided for @file_write_failed_uri.
  ///
  /// In en, this message translates to:
  /// **'Failed to create file {uri}'**
  String file_write_failed_uri(Object uri);

  /// No description provided for @storage_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'No permission to write to file: {uri}'**
  String storage_permission_denied(Object uri);

  /// No description provided for @file_updated.
  ///
  /// In en, this message translates to:
  /// **'File has been modified externally and reloaded.'**
  String get file_updated;

  /// No description provided for @file_created_reopen_again.
  ///
  /// In en, this message translates to:
  /// **'File created! Please use Select File to reopen it, as permanent write access was not granted.'**
  String get file_created_reopen_again;

  /// No description provided for @file_exists.
  ///
  /// In en, this message translates to:
  /// **'File already exists, pick a different one'**
  String get file_exists;

  /// No description provided for @cannot_open_this_type.
  ///
  /// In en, this message translates to:
  /// **'Cannot open this type of file'**
  String get cannot_open_this_type;

  /// No description provided for @unable_to_open_folder.
  ///
  /// In en, this message translates to:
  /// **'Unable to access that folder.'**
  String get unable_to_open_folder;

  /// No description provided for @error_receive_file.
  ///
  /// In en, this message translates to:
  /// **'Unable to open this file.'**
  String get error_receive_file;

  /// No description provided for @confirm_discard_changes.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to exit?'**
  String get confirm_discard_changes;

  /// No description provided for @select_mode.
  ///
  /// In en, this message translates to:
  /// **'Select editor mode:'**
  String get select_mode;

  /// No description provided for @edit_mode.
  ///
  /// In en, this message translates to:
  /// **'Edit as: {mode}'**
  String edit_mode(Object mode);

  /// No description provided for @mode_todo.
  ///
  /// In en, this message translates to:
  /// **'To Do'**
  String get mode_todo;

  /// No description provided for @mode_markdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get mode_markdown;

  /// No description provided for @mode_text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get mode_text;

  /// No description provided for @press_plus_to_create.
  ///
  /// In en, this message translates to:
  /// **'Press + to create a file'**
  String get press_plus_to_create;

  /// No description provided for @tooltip_create.
  ///
  /// In en, this message translates to:
  /// **'Create file'**
  String get tooltip_create;

  /// No description provided for @tooltip_open.
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get tooltip_open;

  /// No description provided for @tooltip_open_folder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get tooltip_open_folder;

  /// No description provided for @tooltip_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltip_settings;

  /// No description provided for @type_task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get type_task;

  /// No description provided for @type_subtask.
  ///
  /// In en, this message translates to:
  /// **'Subtask'**
  String get type_subtask;

  /// No description provided for @type_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get type_date;

  /// No description provided for @type_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get type_title;

  /// No description provided for @type_separator.
  ///
  /// In en, this message translates to:
  /// **'Separator'**
  String get type_separator;

  /// No description provided for @type_empty.
  ///
  /// In en, this message translates to:
  /// **'Empty line'**
  String get type_empty;

  /// No description provided for @type_text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get type_text;

  /// No description provided for @state_open.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get state_open;

  /// No description provided for @state_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get state_done;

  /// No description provided for @state_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get state_rejected;

  /// No description provided for @state_important.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get state_important;

  /// No description provided for @state_under_discussion.
  ///
  /// In en, this message translates to:
  /// **'Under discussion'**
  String get state_under_discussion;

  /// No description provided for @state_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get state_in_progress;

  /// No description provided for @enter_new_content.
  ///
  /// In en, this message translates to:
  /// **'Enter new content'**
  String get enter_new_content;

  /// No description provided for @file_changed.
  ///
  /// In en, this message translates to:
  /// **'File changed'**
  String get file_changed;

  /// No description provided for @file_deleted.
  ///
  /// In en, this message translates to:
  /// **'The file has been deleted on disk. Do you want to keep editing?'**
  String get file_deleted;

  /// No description provided for @file_modified.
  ///
  /// In en, this message translates to:
  /// **'The file has been modified on disk. Do you want to reload it?'**
  String get file_modified;

  /// No description provided for @keep_editing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keep_editing;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @discard_changes.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discard_changes;

  /// No description provided for @enter_file_name.
  ///
  /// In en, this message translates to:
  /// **'Enter file name'**
  String get enter_file_name;

  /// No description provided for @filename_hint.
  ///
  /// In en, this message translates to:
  /// **'todo.txt'**
  String get filename_hint;

  /// No description provided for @insert_next_day.
  ///
  /// In en, this message translates to:
  /// **'Insert next day'**
  String get insert_next_day;

  /// No description provided for @insert_above.
  ///
  /// In en, this message translates to:
  /// **'Insert 1 above'**
  String get insert_above;

  /// No description provided for @insert_below.
  ///
  /// In en, this message translates to:
  /// **'Insert 1 below'**
  String get insert_below;

  /// No description provided for @paste_above.
  ///
  /// In en, this message translates to:
  /// **'Paste above'**
  String get paste_above;

  /// No description provided for @paste_below.
  ///
  /// In en, this message translates to:
  /// **'Paste below'**
  String get paste_below;

  /// No description provided for @insert_subtask.
  ///
  /// In en, this message translates to:
  /// **'Insert subtask'**
  String get insert_subtask;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get remove;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @delete_entry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get delete_entry;

  /// No description provided for @delete_entry_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this entry?'**
  String get delete_entry_confirm;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_section_editor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get settings_section_editor;

  /// No description provided for @setting_autosave.
  ///
  /// In en, this message translates to:
  /// **'Save files automatically'**
  String get setting_autosave;

  /// No description provided for @setting_autosave_descr.
  ///
  /// In en, this message translates to:
  /// **'Save files automatically when leaving the editor'**
  String get setting_autosave_descr;

  /// No description provided for @setting_default_mode.
  ///
  /// In en, this message translates to:
  /// **'Open in text mode by default'**
  String get setting_default_mode;

  /// No description provided for @setting_default_mode_descr.
  ///
  /// In en, this message translates to:
  /// **'When enabled, uses text mode by default, otherwise uses to-do list mode'**
  String get setting_default_mode_descr;

  /// No description provided for @setting_enable_syntax.
  ///
  /// In en, this message translates to:
  /// **'Enable syntax highlighter'**
  String get setting_enable_syntax;

  /// No description provided for @setting_enable_syntax_descr.
  ///
  /// In en, this message translates to:
  /// **'Enables syntax highlighter in text mode'**
  String get setting_enable_syntax_descr;

  /// No description provided for @setting_txt_is_markdown.
  ///
  /// In en, this message translates to:
  /// **'Default to Markdown syntax highlighter'**
  String get setting_txt_is_markdown;

  /// No description provided for @setting_txt_is_markdown_descr.
  ///
  /// In en, this message translates to:
  /// **'Use Markdowm highlighter for .txt files'**
  String get setting_txt_is_markdown_descr;

  /// No description provided for @setting_confirm_discard.
  ///
  /// In en, this message translates to:
  /// **'Confirm discard entry'**
  String get setting_confirm_discard;

  /// No description provided for @setting_confirm_discard_descr.
  ///
  /// In en, this message translates to:
  /// **'When swiping to discard, shows a confirmation dialog to confirm'**
  String get setting_confirm_discard_descr;

  /// No description provided for @setting_enable_swipe.
  ///
  /// In en, this message translates to:
  /// **'Enable swipe gestures'**
  String get setting_enable_swipe;

  /// No description provided for @setting_enable_swipe_descr.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to complete, swipe left to discard'**
  String get setting_enable_swipe_descr;

  /// No description provided for @setting_date_format.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get setting_date_format;

  /// No description provided for @setting_date_format_descr.
  ///
  /// In en, this message translates to:
  /// **'Date format used when inserting a day entry. Uses ICU/JDK date pattern.'**
  String get setting_date_format_descr;

  /// No description provided for @settings_section_file_list.
  ///
  /// In en, this message translates to:
  /// **'File List'**
  String get settings_section_file_list;

  /// No description provided for @setting_limit_file_list.
  ///
  /// In en, this message translates to:
  /// **'Show only .txt and .md files in list'**
  String get setting_limit_file_list;

  /// No description provided for @setting_limit_file_list_descr.
  ///
  /// In en, this message translates to:
  /// **'When disabled, files with all extensions are shown. Applies to newly added folders.'**
  String get setting_limit_file_list_descr;

  /// No description provided for @setting_hidden_files.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files'**
  String get setting_hidden_files;

  /// No description provided for @setting_hidden_files_descr.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files in the file list; only active when all files are shown. Applies to newly added folders.'**
  String get setting_hidden_files_descr;

  /// No description provided for @setting_sort_by_opened.
  ///
  /// In en, this message translates to:
  /// **'Sort most recent first'**
  String get setting_sort_by_opened;

  /// No description provided for @setting_sort_by_opened_descr.
  ///
  /// In en, this message translates to:
  /// **'Sorts most recently opened files to top.'**
  String get setting_sort_by_opened_descr;

  /// No description provided for @settings_section_general.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get settings_section_general;

  /// No description provided for @setting_add_padding_for_desktop.
  ///
  /// In en, this message translates to:
  /// **'Add padding for desktop mode'**
  String get setting_add_padding_for_desktop;

  /// No description provided for @setting_add_padding_for_desktop_descr.
  ///
  /// In en, this message translates to:
  /// **'Adds extra padding so caption bar doesn\'t overlap content in Android\'s desktop mode.'**
  String get setting_add_padding_for_desktop_descr;

  /// No description provided for @setting_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get setting_theme;

  /// No description provided for @setting_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get setting_theme_light;

  /// No description provided for @setting_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get setting_theme_dark;

  /// No description provided for @setting_theme_system.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get setting_theme_system;

  /// No description provided for @setting_theme_descr.
  ///
  /// In en, this message translates to:
  /// **'Choose light or dark mode or follow system settings'**
  String get setting_theme_descr;

  /// No description provided for @setting_force_bright_mode_markdown.
  ///
  /// In en, this message translates to:
  /// **'Bright mode for Markdown editor'**
  String get setting_force_bright_mode_markdown;

  /// No description provided for @setting_force_bright_mode_markdown_descr.
  ///
  /// In en, this message translates to:
  /// **'Forces bright mode, even when in dark mode, for the Markdown editor.'**
  String get setting_force_bright_mode_markdown_descr;

  /// No description provided for @section_header_pinned.
  ///
  /// In en, this message translates to:
  /// **'PINNED'**
  String get section_header_pinned;

  /// No description provided for @section_header_files.
  ///
  /// In en, this message translates to:
  /// **'FILES'**
  String get section_header_files;

  /// No description provided for @section_header_folders.
  ///
  /// In en, this message translates to:
  /// **'FOLDERS'**
  String get section_header_folders;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
