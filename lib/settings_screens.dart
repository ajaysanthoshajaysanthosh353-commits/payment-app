import 'package:flutter/material.dart';

import 'security_screen.dart';
import 'language_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool notification=true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      body: ListView(
        children: [
          // ==========================
          // DARK MODE
          // ==========================
          

        

          // ==========================
          // NOTIFICATIONS
          // ==========================
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('View notifications'),
            trailing: Switch(
              value: notification,
              onChanged: (value) {
                setState(() {
                  notification = value;
                });
              },
            ),
            
          ),
            
          

          const Divider(),

          // ==========================
          // LANGUAGE
          // ==========================
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('Change language'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LanguageScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // ==========================
          // SECURITY
          // ==========================
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security'),
            subtitle: const Text('Manage security settings'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SecurityScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // ==========================
          // ABOUT
          // ==========================
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text(
              'App version and information',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // ==========================
  // ABOUT DIALOG
  // ==========================
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ECpay',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.payment,
        size: 40,
      ),
      children: const [
        Text(
          'ECpay is a simple and secure payment application.',
        ),
      ],
    );
  }
}