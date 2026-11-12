import 'package:flutter/material.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

/// Shown when [ApiConfig] fails validation before the main app starts.
class ApiConfigurationErrorApp extends StatelessWidget {
  const ApiConfigurationErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.settings_suggest_outlined, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'App configuration required',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(message, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
