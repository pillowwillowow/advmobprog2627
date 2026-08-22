import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: SwitchListTile(
            title: Text(
              themeProvider.isDark 
                  ? "Dark Mode"
                  : "Light Mode",
              ),
              subtitle: const Text("Enable or disable dark theme"),
              secondary: Icon(
              themeProvider.isDark // Enhancement 3: Add settings page to move the dark/light mode switch. | DONE.
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            value: themeProvider.isDark,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
        ),
      ),
    );
  }
}