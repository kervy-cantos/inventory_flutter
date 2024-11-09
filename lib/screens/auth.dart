import 'package:flutter/material.dart';
import 'package:inventory_flutter/widgets/login.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColorLight,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Inventory App', style: theme.textTheme.headlineMedium),
          ],
        ),
      ),
      body: const Center(
        child: Login(),
      ),
    );
  }
}
