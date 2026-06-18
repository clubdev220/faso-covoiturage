import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/passenger/presentation/screens/home_screen.dart';
import '../../features/passenger/presentation/screens/trip_search_screen.dart';
import '../../features/passenger/presentation/screens/trip_detail_screen.dart';
import '../../features/passenger/presentation/screens/booking_screen.dart';
import '../../features/passenger/presentation/screens/booking_history_screen.dart';
import '../../features/driver/presentation/screens/publish_trip_screen.dart';
import '../../features/driver/presentation/screens/my_trips_screen.dart';
import '../../features/driver/presentation/screens/booking_management_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/user_management_screen.dart';
import '../../shared/presentation/screens/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation == '/otp';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/otp', builder: (context, state) => OtpVerificationScreen(phone: state.extra as String? ?? '')),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/search', builder: (context, state) => const TripSearchScreen()),
          GoRoute(path: '/trip/:id', builder: (context, state) => TripDetailScreen(tripId: state.pathParameters['id']!)),
          GoRoute(path: '/booking/:tripId', builder: (context, state) => BookingScreen(tripId: state.pathParameters['tripId']!)),
          GoRoute(path: '/history', builder: (context, state) => const BookingHistoryScreen()),
          GoRoute(path: '/publish-trip', builder: (context, state) => const PublishTripScreen()),
          GoRoute(path: '/my-trips', builder: (context, state) => const MyTripsScreen()),
          GoRoute(path: '/trip/:id/bookings', builder: (context, state) => BookingManagementScreen(tripId: state.pathParameters['id']!)),
          GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/users', builder: (context, state) => const UserManagementScreen()),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text('Page non trouvée: ${state.matchedLocation}'))),
  );
});