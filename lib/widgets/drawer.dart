import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_flutter/utils/helpers.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      width: 250, // Fixed width for the drawer
      decoration: BoxDecoration(
        color: Colors.blueGrey[50],
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.webhook, color: Colors.white, size: 32),
                  const SizedBox(width: 10),
                  Text('Menu',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
          ),
          _buildDrawerItem(context, Icons.inventory, 'Inventory', '/overview'),
          _buildDrawerItem(context, Icons.report, 'Reports', '/reports'),
          _buildDrawerItem(context, Icons.settings, 'Settings', '/settings'),

          const Spacer(), // Push logout button to the bottom

          _buildLogoutButton(context), // Logout button
        ],
      ),
    );
  }

  // Drawer item widget that shows both icon and text
  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String text, String route) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title:
          Text(text, style: const TextStyle(color: Colors.black, fontSize: 16)),
      onTap: () {
        context.go(route); // Navigate to the respective route
      },
    );
  }

  // Logout button at the bottom
  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app, size: 28, color: Colors.red),
      title: const Text(
        'Logout',
        style: TextStyle(color: Colors.red, fontSize: 16),
      ),
      onTap: () async {
        bool? shouldLogout = await showLogoutDialog(context);
        if (shouldLogout ?? false) {
          await FirebaseAuth.instance.signOut();
          context.go('/');
        }
      },
    );
  }
}
