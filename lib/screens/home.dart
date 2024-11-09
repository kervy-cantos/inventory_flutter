import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_flutter/router/goRouter.dart';
import 'package:inventory_flutter/screens/auth.dart';
import 'package:inventory_flutter/screens/overview.dart';
import 'package:inventory_flutter/widgets/login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Overview();
            } else {
              return Auth();
            }
          }),
    );
  }
}
