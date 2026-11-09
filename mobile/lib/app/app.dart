import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/theme_provider.dart';
import 'package:pos_mobile/app/router/app_router.dart';
import 'package:pos_mobile/app/theme/app_theme.dart';

/// Root Material app wired to GoRouter and theme state.
class PakPosApp extends ConsumerWidget {
  const PakPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pak POS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
