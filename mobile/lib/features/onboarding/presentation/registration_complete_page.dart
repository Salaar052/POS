import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/onboarding_providers.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

/// Shown after remote registration and local provisioning while owner auth is deferred.
class RegistrationCompletePage extends ConsumerWidget {
  const RegistrationCompletePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pendingAsync = ref.watch(ownerPendingSnapshotProvider);
    final snapshot =
        pendingAsync.value is OnboardingSnapshotPresent<OwnerPendingSnapshot>
        ? (pendingAsync.value!
                  as OnboardingSnapshotPresent<OwnerPendingSnapshot>)
              .value
        : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Business account created',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (snapshot != null) ...[
                    Text(
                      snapshot.businessName,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Owner: ${snapshot.ownerName} (${snapshot.ownerEmail})',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Your local POS database is ready on this device, but you are not signed in. '
                    'Owner verification and login will be added in a later phase. '
                    'No verification email has been sent.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Protected POS features stay locked until authentication is implemented.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
