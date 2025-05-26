import 'package:flutter/material.dart';
import 'package:flutter_donation_buttons/flutter_donation_buttons.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/theme/theme.dart';
import 'package:todo/theme/theme_controller.dart';
import 'package:todo/utils/preferences_manager.dart';
import 'package:todo/widgets/option_button.dart';
import 'package:todo/widgets/text_setting.dart';
import 'package:todo/widgets/toggle_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

/// State class for [SettingsScreen].
/// Contains an About text, the version number, and a list of settings, etc.
class SettingsScreenState extends State<SettingsScreen> {
  PreferenceManager? preferenceManager;
  String version = '';

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      preferenceManager = PreferenceManager(prefs);
    });
  }

  /// Gets the version number from the package info.
  void _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = 'v${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  /// Launches the given [urlString] in the browser
  void _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (context.mounted &&
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackbar('Could not launch $urlString');
    }
  }

  /// Shows a snackbar with the given [message].
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadPrefs();
    });
  }

  Widget _buildInfoSection(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(height: 16.0),
        // App Logo and Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: locale.app_name_shorter,
                    style: theme.titleLarge?.copyWith(fontSize: 24),
                  ),
                  TextSpan(
                    text: '.',
                    style: AppTheme.titleTextStyle
                        .copyWith(fontSize: 24, color: AppTheme.orange),
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 4.0),
        // Small text, the version number:
        Text(
          version,
          style: AppTheme.entryTextStyle
              .copyWith(fontSize: 12.0, color: AppTheme.dimmed),
        ),
        SizedBox(height: 16.0),

        // Donation and Support links
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // Ko-fi Donation Button
              Theme(
                  data: AppTheme.themeData.copyWith(
                      elevatedButtonTheme: ElevatedButtonThemeData(
                    style:
                        AppTheme.themeData.elevatedButtonTheme.style!.copyWith(
                      iconColor: WidgetStateProperty.all<Color>(Colors.white),
                    ),
                  )),
                  child: KofiButton(
                    kofiName: locale.kofi_name,
                    kofiColor: KofiColor.Red,
                    onDonation: () {
                      // show a thankful message
                      _showSnackbar(locale.thank_you);
                    },
                  )),

              SizedBox(height: 8),

              // Links Section
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  // Website Link
                  TextButton(
                    onPressed: () => _launchUrl(locale.website),
                    child: Text(locale.settings_website),
                  ),

                  // GitHub Link
                  TextButton(
                    onPressed: () => _launchUrl(locale.github),
                    child: Text(locale.settings_github),
                  ),

                  // Feedback/Support
                  TextButton(
                    onPressed: () => _launchUrl(
                        'mailto:${locale.email}?subject=${locale.feedback_subject}$version'),
                    child: Text(locale.settings_feedback),
                  ),
                ],
              ),

              // App description
              SizedBox(height: 8),
              Text(
                locale.settings_intro,
                textAlign: TextAlign.justify,
              ),

              SizedBox(height: 32),

              // Privacy and Terms
              RichText(
                text: TextSpan(
                  style: AppTheme.entryTextStyle
                      .copyWith(color: AppTheme.dimmed, fontSize: 12),
                  children: [
                    TextSpan(text: locale.settings_privacy),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.0),
        Divider(),
        SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.settings_title),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(minWidth: 100, maxWidth: 600),
          padding: EdgeInsets.all(8.0),
          child: ListView(
            children: [
              // App info
              _buildInfoSection(context),

              // Editor section
              SizedBox(height: 8.0),
              ListTile(
                  title: Text(
                locale.settings_section_editor,
                style: theme.titleMedium,
              )),
              // TODO autosave is disabled for now, because we don't have undo yet.
              // We will re-enable it later, but differently. Not on exit, but every x seconds.
              // ToggleButton(
              //   title: locale.setting_autosave,
              //   description: locale.setting_autosave_descr,
              //   value: preferenceManager?.autosave ?? false,
              //   onSettingChanged: (value) {
              //     setState(() {
              //       preferenceManager?.autosave = value;
              //     });
              //   },
              // ),
              ToggleButton(
                title: locale.setting_default_mode,
                description: locale.setting_default_mode_descr,
                value: preferenceManager?.defaultModeText ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.defaultModeText = value;
                  });
                },
              ),
              ToggleButton(
                title: locale.setting_enable_syntax,
                description: locale.setting_enable_syntax_descr,
                value: preferenceManager?.enableSyntax ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.enableSyntax = value;
                  });
                },
              ),
              ToggleButton(
                title: locale.setting_txt_is_markdown,
                description: locale.setting_txt_is_markdown_descr,
                value: preferenceManager?.txtIsMarkdown ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.txtIsMarkdown = value;
                  });
                },
              ),
              ToggleButton(
                title: locale.setting_enable_swipe,
                description: locale.setting_enable_swipe_descr,
                value: preferenceManager?.enableSwipe ?? true,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.enableSwipe = value;
                  });
                },
              ),
              ToggleButton(
                enabled: preferenceManager?.enableSwipe != false,
                title: locale.setting_confirm_discard,
                description: locale.setting_confirm_discard_descr,
                value: preferenceManager?.confirmDiscard ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.confirmDiscard = value;
                  });
                },
              ),
              TextSetting(
                enabled: true,
                title: locale.setting_date_format,
                description: locale.setting_date_format_descr,
                value: preferenceManager?.dateFormat ??
                    PreferenceManager.defaultDateFormat,
                onSettingChanged: (value) {
                  preferenceManager?.dateFormat = value;
                },
              ),

              // File List section
              SizedBox(height: 8.0),
              ListTile(
                  title: Text(
                locale.settings_section_file_list,
                style: theme.titleMedium,
              )),
              ToggleButton(
                title: locale.setting_limit_file_list,
                description: locale.setting_limit_file_list_descr,
                value: preferenceManager?.limitToTxtAndMD ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.limitToTxtAndMD = value;
                  });
                },
              ),
              ToggleButton(
                enabled: preferenceManager?.limitToTxtAndMD != true,
                title: locale.setting_hidden_files,
                description: locale.setting_hidden_files_descr,
                value: preferenceManager?.showHiddenFiles ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.showHiddenFiles = value;
                  });
                },
              ),
              ToggleButton(
                enabled: true,
                title: locale.setting_sort_by_opened,
                description: locale.setting_sort_by_opened_descr,
                value: preferenceManager?.sortByOpened ?? true,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.sortByOpened = value;
                  });
                },
              ),

              // General section
              SizedBox(height: 8.0),
              ListTile(
                  title: Text(
                locale.settings_section_general,
                style: theme.titleMedium,
              )),
              OptionButton(
                title: locale.setting_theme,
                description: locale.setting_theme_descr,
                value: (preferenceManager?.theme ?? ThemeMode.light).index,
                values: [
                  locale.setting_theme_system,
                  locale.setting_theme_light,
                  locale.setting_theme_dark,
                ],
                onSettingChanged: (value) {
                  setState(() {
                    // preferenceManager?.theme = ThemeMode.values[value];
                    ThemeController.of(context)
                        .setTheme(ThemeMode.values[value]);
                  });
                },
              ),
              ToggleButton(
                enabled: preferenceManager?.theme != ThemeMode.light,
                title: locale.setting_force_bright_mode_markdown,
                description: locale.setting_force_bright_mode_markdown_descr,
                value: preferenceManager?.forceBrightModeMarkdown ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.forceBrightModeMarkdown = value;
                  });
                },
              ),
              ToggleButton(
                title: locale.setting_add_padding_for_desktop,
                description: locale.setting_add_padding_for_desktop_descr,
                value: preferenceManager?.fixPadding ?? false,
                onSettingChanged: (value) {
                  setState(() {
                    preferenceManager?.fixPadding = value;
                  });
                },
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
