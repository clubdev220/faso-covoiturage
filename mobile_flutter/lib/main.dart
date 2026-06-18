import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/di/providers.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FasoCovoiturageApp(),
    ),
  );
}

class FasoCovoiturageApp extends ConsumerWidget {
  const FasoCovoiturageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Faso Covoiturage',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}