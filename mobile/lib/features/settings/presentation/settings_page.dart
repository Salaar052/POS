import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/bootstrap/app_runtime.dart';
import 'package:pos_mobile/app/providers/app_launch_provider.dart';
import 'package:pos_mobile/app/providers/auth_providers.dart';
import 'package:pos_mobile/app/providers/theme_provider.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Appearance and device preferences. Business and account settings are not available in this phase.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: ListTile(
                title: const Text('Sign out'),
                subtitle: const Text(
                  'Revokes this device sign-in and returns to the login screen.',
                ),
                trailing: const Icon(Icons.logout),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final serverRevoked = await ref
                      .read(authSessionControllerProvider)
                      .logout();
                  await AppRuntime.switchToBootstrap();
                  ref.invalidate(appLaunchResolutionProvider);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        serverRevoked
                            ? 'Signed out.'
                            : 'Signed out on this device. Server revocation '
                                  'could not be confirmed.',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: SwitchListTile(
                  title: const Text('Dark theme'),
                  subtitle: const Text(
                    'Switch between light and dark appearance',
                  ),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (enabled) {
                    notifier.setThemeMode(
                      enabled ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
