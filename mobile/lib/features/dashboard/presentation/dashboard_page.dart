import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/business_status_provider.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';
import 'package:pos_mobile/features/reporting/presentation/dashboard_reporting_body.dart';
import 'package:pos_mobile/app/theme/app_colors.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final businessAsync = ref.watch(businessProvisionStatusProvider);
    final service = ref.watch(databaseServiceProvider);

    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome to Pak POS', style: theme.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Business overview from your offline database (Pakistan business days, PKR).',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _StatusCard(
              title: 'Local database',
              icon: Icons.storage_outlined,
              value: 'Connected (schema v${service.database.schemaVersion})',
              detail: service.businessId == null
                  ? 'Bootstrap database — business not selected.'
                  : 'Business database: ${service.businessId}',
              accent: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),
            businessAsync.when(
              loading: () => const _StatusCard(
                title: 'Business',
                icon: Icons.store_outlined,
                value: 'Checking…',
                detail: null,
                accent: AppColors.slate500,
              ),
              error: (error, _) => _StatusCard(
                title: 'Business',
                icon: Icons.error_outline,
                value: 'Unable to read status',
                detail: 'Try restarting the app.',
                accent: AppColors.error,
              ),
              data: (status) {
                if (status.isProvisioned) {
                  return _StatusCard(
                    title: 'Business',
                    icon: Icons.store,
                    value: status.businessName ?? 'Provisioned',
                    detail: 'Currency: ${status.currencyCode ?? 'PKR'}',
                    accent: AppColors.accentBlue,
                  );
                }
                return _StatusCard(
                  title: 'Business',
                  icon: Icons.store_outlined,
                  value: 'Not provisioned',
                  detail: 'No business record on this device. Setup flows arrive in Phase 4.',
                  accent: AppColors.warning,
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            if (service.businessId != null)
              const CatalogAccessGate(child: DashboardReportingBody()),
            if (service.businessId != null)
              const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Use the navigation for POS, customers, inventory, and purchasing.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final String title;
  final IconData icon;
  final String value;
  final String? detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(value, style: theme.textTheme.titleMedium),
                  if (detail != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      detail!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
