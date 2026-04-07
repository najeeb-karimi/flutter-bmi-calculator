import 'package:flutter/material.dart';

/// Basic settings shell screen.
///
/// Phase 6.1 adds navigation and a settings scaffold only.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.straighten),
            title: Text('Default units'),
            subtitle: Text('Configure metric or imperial as default'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.brightness_6_outlined),
            title: Text('Theme'),
            subtitle: Text('System / Light / Dark'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
