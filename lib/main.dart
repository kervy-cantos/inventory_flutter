import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inventory_flutter/provider/inventory_provider.dart';
import 'package:inventory_flutter/router/goRouter.dart';

import '../utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  if (kIsWeb) {
    print('The app is running as a web app.');
  } else if (Platform.isWindows) {
    await dotenv.load();
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: dotenv.env['FIREBASE_API_KEY']!,
            authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
            projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
            storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
            messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
            appId: dotenv.env['FIREBASE_APP_ID']!,
            measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!));
    WindowManager.instance.setMinimumSize(const Size(1400, 800));
    WindowManager.instance.setMaximumSize(const Size(1400, 800));
  } else {
    print('The app is running on another platform.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = MaterialTheme(TextTheme());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => InventoryProvider()),
      ],
      child: MaterialApp.router(
        theme: theme.light().copyWith(
              textTheme:
                  MaterialTheme.customTextTheme(MaterialTheme.lightScheme()),
            ),
        darkTheme: theme.darkMediumContrast(),
        themeMode: ThemeMode.system,
        title: 'Inventory System',
        routerConfig: goRouter,
      ),
    );
  }
}
