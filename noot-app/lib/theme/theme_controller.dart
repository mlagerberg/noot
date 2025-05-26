import 'package:flutter/material.dart';
import 'package:todo/utils/preferences_manager.dart';

/// Uses the user's settings to set the theme and notify the app of changes.
class ThemeController extends ChangeNotifier {
  final PreferenceManager _prefs;
  late ThemeMode _currentTheme;

  ThemeMode get currentTheme => _currentTheme;

  ThemeController(this._prefs) {
    _currentTheme = _prefs.theme;
  }

  void setTheme(ThemeMode theme) {
    _currentTheme = theme;
    notifyListeners();
    _prefs.theme = theme;
  }

  /// Gives access to the controller from throughout the app
  static ThemeController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerProvider>()
            as ThemeControllerProvider;
    return provider.controller;
  }
}

/// Provider for the ThemeController
class ThemeControllerProvider extends InheritedWidget {
  const ThemeControllerProvider(
      {required Key super.key, required this.controller, required super.child});

  final ThemeController controller;

  @override
  bool updateShouldNotify(ThemeControllerProvider old) =>
      controller != old.controller;
}
