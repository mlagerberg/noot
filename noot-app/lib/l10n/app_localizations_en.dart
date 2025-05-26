// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Noot. (beta)';

  @override
  String get app_name_short => 'Noot.';

  @override
  String get app_name_shorter => 'Noot';

  @override
  String get kofi_url => 'https://ko-fi.com/mathijsl';

  @override
  String get kofi_name => 'mathijsl';

  @override
  String get thank_you => 'Thank you! You rock!';

  @override
  String get settings_intro => 'This app is an editor text files, markdown, and for its own nameless to-do format. It is completely offline, has no cloud, and relies on your own Dropbox, Syncthing, rsync or other sync solution to work. It is fully compatible with plain text editors.\n\nCurrently in BETA, but there are plans to open source soon.\n\nCreated by Mathijs Lagerberg // mlagerberg.com\n\n';

  @override
  String get settings_privacy => 'This app does not collect any data, and therefore has no privacy policy.';

  @override
  String get settings_website => 'Website';

  @override
  String get website => 'https://mlagerberg.com/noot/';

  @override
  String get settings_github => 'GitHub';

  @override
  String get github => 'https://github.com/mlagerberg/';

  @override
  String get settings_feedback => 'Send Feedback';

  @override
  String get email => 'noot@mlagerberg.com';

  @override
  String get feedback_subject => 'Feedback on Noot app ';

  @override
  String get confirm => 'Confirm';

  @override
  String get untitled => 'Untitled';

  @override
  String get cancel => 'Cancel';

  @override
  String get discard => 'Discard';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get date_yesterday => 'Yesterday';

  @override
  String date_hours_ago(Object h) {
    return '$h hours ago';
  }

  @override
  String get date_an_hour_ago => 'An hour ago';

  @override
  String date_minutes_ago(Object m) {
    return '$m minutes ago';
  }

  @override
  String get date_a_minute_ago => 'A minute ago';

  @override
  String get date_just_now => 'Just now';

  @override
  String get abbr_monday => 'Mon';

  @override
  String get abbr_tuesday => 'Tue';

  @override
  String get abbr_wednesday => 'Wed';

  @override
  String get abbr_thursday => 'Thu';

  @override
  String get abbr_friday => 'Fri';

  @override
  String get abbr_saturday => 'Sat';

  @override
  String get abbr_sunday => 'Sun';

  @override
  String get abbr_monday_2 => 'ma';

  @override
  String get abbr_tuesday_2 => 'di';

  @override
  String get abbr_wednesday_2 => 'wo';

  @override
  String get abbr_thursday_2 => 'do';

  @override
  String get abbr_friday_2 => 'vr';

  @override
  String get abbr_saturday_2 => 'za';

  @override
  String get abbr_sunday_2 => 'zo';

  @override
  String get file_saved => 'File saved';

  @override
  String get file_write_failed => 'Failed to write to file';

  @override
  String file_write_failed_uri(Object uri) {
    return 'Failed to create file $uri';
  }

  @override
  String storage_permission_denied(Object uri) {
    return 'No permission to write to file: $uri';
  }

  @override
  String get file_updated => 'File has been modified externally and reloaded.';

  @override
  String get file_created_reopen_again => 'File created! Please use Select File to reopen it, as permanent write access was not granted.';

  @override
  String get file_exists => 'File already exists, pick a different one';

  @override
  String get cannot_open_this_type => 'Cannot open this type of file';

  @override
  String get unable_to_open_folder => 'Unable to access that folder.';

  @override
  String get error_receive_file => 'Unable to open this file.';

  @override
  String get confirm_discard_changes => 'You have unsaved changes. Do you want to exit?';

  @override
  String get select_mode => 'Select editor mode:';

  @override
  String edit_mode(Object mode) {
    return 'Edit as: $mode';
  }

  @override
  String get mode_todo => 'To Do';

  @override
  String get mode_markdown => 'Markdown';

  @override
  String get mode_text => 'Text';

  @override
  String get press_plus_to_create => 'Press + to create a file';

  @override
  String get tooltip_create => 'Create file';

  @override
  String get tooltip_open => 'Open file';

  @override
  String get tooltip_open_folder => 'Open folder';

  @override
  String get tooltip_settings => 'Settings';

  @override
  String get type_task => 'Task';

  @override
  String get type_subtask => 'Subtask';

  @override
  String get type_date => 'Date';

  @override
  String get type_title => 'Title';

  @override
  String get type_separator => 'Separator';

  @override
  String get type_empty => 'Empty line';

  @override
  String get type_text => 'Text';

  @override
  String get state_open => 'To do';

  @override
  String get state_done => 'Done';

  @override
  String get state_rejected => 'Rejected';

  @override
  String get state_important => 'Important';

  @override
  String get state_under_discussion => 'Under discussion';

  @override
  String get state_in_progress => 'In progress';

  @override
  String get enter_new_content => 'Enter new content';

  @override
  String get file_changed => 'File changed';

  @override
  String get file_deleted => 'The file has been deleted on disk. Do you want to keep editing?';

  @override
  String get file_modified => 'The file has been modified on disk. Do you want to reload it?';

  @override
  String get keep_editing => 'Keep editing';

  @override
  String get reload => 'Reload';

  @override
  String get discard_changes => 'Discard changes';

  @override
  String get enter_file_name => 'Enter file name';

  @override
  String get filename_hint => 'todo.txt';

  @override
  String get insert_next_day => 'Insert next day';

  @override
  String get insert_above => 'Insert 1 above';

  @override
  String get insert_below => 'Insert 1 below';

  @override
  String get paste_above => 'Paste above';

  @override
  String get paste_below => 'Paste below';

  @override
  String get insert_subtask => 'Insert subtask';

  @override
  String get cut => 'Cut';

  @override
  String get copy => 'Copy';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get search => 'Search';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get share => 'Share';

  @override
  String get remove => 'Remove from list';

  @override
  String get refresh => 'Refresh';

  @override
  String get delete_entry => 'Delete entry';

  @override
  String get delete_entry_confirm => 'Are you sure you want to delete this entry?';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_section_editor => 'Editor';

  @override
  String get setting_autosave => 'Save files automatically';

  @override
  String get setting_autosave_descr => 'Save files automatically when leaving the editor';

  @override
  String get setting_default_mode => 'Open in text mode by default';

  @override
  String get setting_default_mode_descr => 'When enabled, uses text mode by default, otherwise uses to-do list mode';

  @override
  String get setting_enable_syntax => 'Enable syntax highlighter';

  @override
  String get setting_enable_syntax_descr => 'Enables syntax highlighter in text mode';

  @override
  String get setting_txt_is_markdown => 'Default to Markdown syntax highlighter';

  @override
  String get setting_txt_is_markdown_descr => 'Use Markdowm highlighter for .txt files';

  @override
  String get setting_confirm_discard => 'Confirm discard entry';

  @override
  String get setting_confirm_discard_descr => 'When swiping to discard, shows a confirmation dialog to confirm';

  @override
  String get setting_enable_swipe => 'Enable swipe gestures';

  @override
  String get setting_enable_swipe_descr => 'Swipe right to complete, swipe left to discard';

  @override
  String get setting_date_format => 'Date format';

  @override
  String get setting_date_format_descr => 'Date format used when inserting a day entry. Uses ICU/JDK date pattern.';

  @override
  String get settings_section_file_list => 'File List';

  @override
  String get setting_limit_file_list => 'Show only .txt and .md files in list';

  @override
  String get setting_limit_file_list_descr => 'When disabled, files with all extensions are shown. Applies to newly added folders.';

  @override
  String get setting_hidden_files => 'Show hidden files';

  @override
  String get setting_hidden_files_descr => 'Show hidden files in the file list; only active when all files are shown. Applies to newly added folders.';

  @override
  String get setting_sort_by_opened => 'Sort most recent first';

  @override
  String get setting_sort_by_opened_descr => 'Sorts most recently opened files to top.';

  @override
  String get settings_section_general => 'Interface';

  @override
  String get setting_add_padding_for_desktop => 'Add padding for desktop mode';

  @override
  String get setting_add_padding_for_desktop_descr => 'Adds extra padding so caption bar doesn\'t overlap content in Android\'s desktop mode.';

  @override
  String get setting_theme => 'Theme';

  @override
  String get setting_theme_light => 'Light';

  @override
  String get setting_theme_dark => 'Dark';

  @override
  String get setting_theme_system => 'Auto';

  @override
  String get setting_theme_descr => 'Choose light or dark mode or follow system settings';

  @override
  String get setting_force_bright_mode_markdown => 'Bright mode for Markdown editor';

  @override
  String get setting_force_bright_mode_markdown_descr => 'Forces bright mode, even when in dark mode, for the Markdown editor.';

  @override
  String get section_header_pinned => 'PINNED';

  @override
  String get section_header_files => 'FILES';

  @override
  String get section_header_folders => 'FOLDERS';
}
