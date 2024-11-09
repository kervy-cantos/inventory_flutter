import 'package:flutter/material.dart';

Future<bool?> showLogoutDialog(BuildContext context) async {
  ThemeData theme = Theme.of(context);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must choose an option
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Confirm Logout',
          style: theme.textTheme.headlineMedium,
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User chose No
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User chose Yes
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
