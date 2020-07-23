import 'package:flutter/cupertino.dart';

import 'dark_theme_preference.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    if(_darkTheme == value) return;

    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);

    notifyListeners();
  }
}
