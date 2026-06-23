import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrueTrack/services/service_registry.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final registry = context.watch<ServiceRegistry>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mock Mode'),
            subtitle: Text(registry.mockMode
                ? 'Using mock data instead of real APIs'
                : 'Using real API services'),
            value: registry.mockMode,
            onChanged: (value) => registry.setMockMode(value),
            secondary: Icon(
              registry.mockMode ? Icons.bug_report : Icons.cloud_done,
              color: registry.mockMode ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
