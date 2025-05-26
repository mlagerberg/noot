import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/l10n/app_localizations.dart';
import 'package:todo/repository/file_manager.dart';
import 'package:todo/screens/master_detail_container.dart';
import 'package:todo/theme/theme.dart';
import 'package:todo/theme/theme_controller.dart';
import 'package:todo/utils/file_io_manager.dart';
import 'package:todo/utils/navigator.dart';
import 'package:todo/utils/preferences_manager.dart';
import 'package:todo/utils/snackbar_fixer.dart' as snackbar_fixer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Right off the bat we load the prefs, syncronously, because
  // it is needed for the theme controller.
  final prefs = PreferenceManager(await SharedPreferences.getInstance());
  final themeController = ThemeController(prefs);

  runApp(ChangeNotifierProvider(
    create: (_) => FileIOManager(),
    child: MyApp(themeController: themeController),
  ));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder to listen to theme changes (listen to ChangeNotifier)
    // so we can respond to light/dark mode theme changes
    return AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          // The provider makes sure we can access the theme throughout the app
          return ThemeControllerProvider(
              controller: themeController,
              key: Key("themeController"),
              child: MaterialApp(
                title: 'Noot.',
                navigatorKey: navigatorKey,
                theme: AppTheme.lightThemeData,
                darkTheme: AppTheme.themeData,
                themeMode: themeController.currentTheme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                // Main content of the app
                home: const MasterDetailContainer(),
                // Hide banner when making screenshots:
                debugShowCheckedModeBanner: kDebugMode &&
                    !FileManager.enableDemoMode &&
                    FileManager.showBanner,
                scaffoldMessengerKey: snackbar_fixer.scaffoldMessengerKey,
              ));
        });
  }
}
