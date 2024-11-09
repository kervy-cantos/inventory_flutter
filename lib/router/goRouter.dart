import 'package:go_router/go_router.dart';
import 'package:inventory_flutter/screens/home.dart';
import 'package:inventory_flutter/screens/overview.dart';
import 'package:inventory_flutter/screens/reports.dart';

final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/overview', builder: (context, state) => const Overview()),
    GoRoute(
        path: '/reports', builder: (context, state) => const ReportsScreen()),
  ],
);
