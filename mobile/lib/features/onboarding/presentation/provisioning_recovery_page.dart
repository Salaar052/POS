import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/providers/app_launch_provider.dart';
import 'package:pos_mobile/app/providers/onboarding_providers.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/data/onboarding_storage_outcomes.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

class ProvisioningRecoveryPage extends ConsumerStatefulWidget {
  const ProvisioningRecoveryPage({super.key});

  @override
  ConsumerState<ProvisioningRecoveryPage> createState() =>
      _ProvisioningRecoveryPageState();
}

class _ProvisioningRecoveryPageState
    extends ConsumerState<ProvisioningRecoveryPage> {
  bool _busy = false;
  String? _error;

  Future<void> _retry() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(businessRegistrationControllerProvider)
          .retryLocalProvisioningFromRecovery();
      if (!mounted) return;
      ref.invalidate(appLaunchResolutionProvider);
      context.go(AppRoutes.onboardingComplete);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Local setup failed. Your online registration is saved — do not register again.';
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recoveryAsync = ref.watch(provisioningRecoverySnapshotProvider);
    final recovery =
        recoveryAsync.value
            is OnboardingSnapshotPresent<ProvisioningRecoverySnapshot>
        ? (recoveryAsync.value!
                  as OnboardingSnapshotPresent<ProvisioningRecoverySnapshot>)
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
                  Text(
                    'Finish local setup',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your business was registered with Pak POS online, but the on-device database '
                    'could not be created yet.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (recovery != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${recovery.displayName}\n${recovery.ownerEmail}',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _busy ? null : _retry,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Retry local setup'),
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
