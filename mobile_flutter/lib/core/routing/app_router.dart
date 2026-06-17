import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/passenger/presentation/screens/home_screen.dart';
import '../../features/passenger/presentation/screens/trip_search_screen.dart';
import '../../features/driver/presentation/screens/publish_trip_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const TripSearchScreen(),
    ),
    GoRoute(
      path: '/publish-trip',
      builder: (context, state) => const PublishTripScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);