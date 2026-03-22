import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../myapp.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePref();
  }

  Future<void> _loadThemePref() async {
    await ThemeNotifier.instance.loadTheme();
    _themeMode = ThemeNotifier.instance.value;
    if (mounted) setState(() {});
  }

  Future<void> _saveThemePref(ThemeMode mode) async {
    await ThemeNotifier.instance.saveTheme(mode);
    setState(() => _themeMode = mode);
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All data reset!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: _themeMode,
              items: ThemeMode.values
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(
                        mode
                            .toString()
                            .split('.')
                            .last
                            .split('Mode')[0]
                            .replaceAll('dark', 'Dark')
                            .replaceAll('light', 'Light'),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => _saveThemePref(value!),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Colors.red),
            title: const Text('Reset All Data'),
            subtitle: const Text('Clears counters and prefs'),
            textColor: Colors.red,
            onTap: _resetData,
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text(
              'Multi-Counter v1.0\nPersistent, history, step size',
            ),
          ),
        ],
      ),
    );
  }
}
