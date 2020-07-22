import 'package:flutter/material.dart';
import 'package:protapp/protogen_provider.dart';
import 'package:protapp/routes/scan/page.dart';
import 'package:protapp/routes/startup/page.dart';
import 'package:provider/provider.dart';

import 'bluetooth_provider.dart';
import 'dark_theme_provider.dart';
import 'dark_theme_styles.dart';
import 'routes/home/page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  ProtogenProvider protogenProvider = new ProtogenProvider();

  @override
  void initState() {
    super.initState();

    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeChangeProvider),
          ChangeNotifierProvider.value(value: protogenProvider),
      ],
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            title: 'ProtOS',
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            initialRoute: '/',
            routes: {
              '/': (context) => StartupRoute(),
              '/scan': (context) => ScanRoute(),
              '/home': (context) => HomeRoute(),
            },
          );
        },
      ),
    );
  }
}
