import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/business_status_provider.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/app/providers/auth_providers.dart';

enum CatalogAccessStatus {
  ready,
  bootstrapDatabase,
  businessNotProvisioned,
  sessionMismatch,
}

final catalogAccessStatusProvider = Provider<CatalogAccessStatus>((ref) {
  final service = ref.watch(databaseServiceProvider);
  if (service.isBootstrap) {
    return CatalogAccessStatus.bootstrapDatabase;
  }
  final provisioned = ref.watch(businessProvisionStatusProvider).value;
  if (provisioned != null && !provisioned.isProvisioned) {
    return CatalogAccessStatus.businessNotProvisioned;
  }
  final sessionId = ref.watch(authSessionControllerProvider).activeBusinessId;
  if (sessionId != null && service.businessId != sessionId) {
    return CatalogAccessStatus.sessionMismatch;
  }
  return CatalogAccessStatus.ready;
});

class CatalogAccessGate extends ConsumerWidget {
  const CatalogAccessGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(catalogAccessStatusProvider);
    if (status == CatalogAccessStatus.ready) {
      return child;
    }
    final theme = Theme.of(context);
    final message = switch (status) {
      CatalogAccessStatus.bootstrapDatabase =>
        'Product catalog requires a business database. '
            'Sign in to open your shop file.',
      CatalogAccessStatus.businessNotProvisioned =>
        'This business database is not provisioned yet.',
      CatalogAccessStatus.sessionMismatch =>
        'The open database does not match your signed-in business. '
            'Sign out and sign in again.',
      CatalogAccessStatus.ready => '',
    };
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(message, style: theme.textTheme.bodyLarge),
          ),
        ),
      ),
    );
  }
}
