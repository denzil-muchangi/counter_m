import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home/home_page.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  static final ThemeNotifier instance = ThemeNotifier();

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    value =
        ThemeMode.values[prefs.getInt('theme_mode') ?? ThemeMode.system.index];
  }

  Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    value = mode;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeNotifier.instance.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier.instance,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Counter App',
          themeMode: themeMode,
          theme: lightTheme(),
          darkTheme: darkTheme(),
          home: const HomePage(title: 'Counter App HomePage'),
        );
      },
    );
  }
}
