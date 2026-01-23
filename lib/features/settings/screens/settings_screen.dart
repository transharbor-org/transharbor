import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Show theme picker
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Privacy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility),
            title: const Text('Profile Visibility'),
            subtitle: const Text('Show profile to other users'),
            value: true,
            onChanged: (value) {
              // Update setting
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.location_on),
            title: const Text('Share Location'),
            subtitle: const Text('Share approximate location'),
            value: false,
            onChanged: (value) {
              // Update setting
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: true,
            onChanged: (value) {
              // Update setting
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.message),
            title: const Text('Message Notifications'),
            subtitle: const Text('Notify on new messages'),
            value: true,
            onChanged: (value) {
              // Update setting
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.how_to_vote),
            title: const Text('Governance Notifications'),
            subtitle: const Text('Notify on new proposals'),
            value: true,
            onChanged: (value) {
              // Update setting
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Navigate to change password
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            onTap: () {
              // Show delete account dialog
            },
          ),
        ],
      ),
    );
  }
}
