import 'package:flutter/material.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/reporting/domain/reporting_models.dart';

class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(value, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ReportMoneyMetricCard extends StatelessWidget {
  const ReportMoneyMetricCard({
    super.key,
    required this.title,
    required this.minor,
    this.subtitle,
  });

  final String title;
  final int minor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ReportMetricCard(
      title: title,
      value: '${MoneyAmount.formatPkrFromMinor(minor)} PKR',
      subtitle: subtitle,
    );
  }
}

class ReportUnavailableMetricCard extends StatelessWidget {
  const ReportUnavailableMetricCard({
    super.key,
    required this.title,
    required this.reason,
  });

  final String title;
  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Not available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              reason,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget metricAvailabilityMoneyCard({
  required String title,
  required MetricAvailability<int> metric,
}) {
  if (metric.isAvailable) {
    return ReportMoneyMetricCard(title: title, minor: metric.value!);
  }
  return ReportUnavailableMetricCard(
    title: title,
    reason: metric.unavailableReason ?? 'Unavailable',
  );
}
