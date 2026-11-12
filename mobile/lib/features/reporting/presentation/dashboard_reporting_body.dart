import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/reporting_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/features/reporting/presentation/report_charts.dart';
import 'package:pos_mobile/features/reporting/presentation/report_metric_widgets.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/reporting/domain/reporting_models.dart';
import 'package:pos_mobile/features/reporting/presentation/report_period_chips.dart';

class DashboardReportingBody extends ConsumerWidget {
  const DashboardReportingBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(dashboardSnapshotProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReportPeriodChips(),
        const SizedBox(height: AppSpacing.md),
        snapshotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Could not load dashboard: $e'),
          data: (snap) => _DashboardMetrics(snapshot: snap),
        ),
      ],
    );
  }
}

class _DashboardMetrics extends StatelessWidget {
  const _DashboardMetrics({required this.snapshot});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final sales = snapshot.sales;
    final purchases = snapshot.purchases;
    final inventory = snapshot.inventory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Sales overview', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cols = w > 900
                ? 4
                : w > 600
                ? 2
                : 1;
            final tileW = (w - (cols - 1) * AppSpacing.sm) / cols;
            Widget tile(Widget child) => SizedBox(width: tileW, child: child);
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                tile(
                  ReportMoneyMetricCard(
                    title: 'Net sales (revenue)',
                    minor: sales.netSalesMinor,
                    subtitle: '${sales.saleCount} completed sale(s)',
                  ),
                ),
                tile(
                  ReportMoneyMetricCard(
                    title: 'Discounts',
                    minor: sales.discountMinor,
                  ),
                ),
                tile(
                  ReportMoneyMetricCard(
                    title: 'Sale returns',
                    minor: sales.returnsMinor,
                  ),
                ),
                tile(
                  ReportMetricCard(
                    title: 'Avg sale value',
                    value: sales.averageSaleMinor == null
                        ? '—'
                        : '${MoneyAmount.formatPkrFromMinor(sales.averageSaleMinor!)} PKR',
                    subtitle: 'Based on net sales',
                  ),
                ),
                tile(
                  ReportMoneyMetricCard(
                    title: 'Checkout collections',
                    minor: sales.checkoutCollectionsMinor,
                    subtitle: 'POS payments only',
                  ),
                ),
                tile(
                  ReportMoneyMetricCard(
                    title: 'Customer account payments',
                    minor: sales.customerAccountPaymentsMinor,
                    subtitle: 'Not counted as sales revenue',
                  ),
                ),
                tile(
                  ReportMoneyMetricCard(
                    title: 'Outstanding receivables',
                    minor: snapshot.customerReceivablesMinor,
                    subtitle: 'Current ledger balance',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        DailyTrendBarChart(points: sales.dailyNetSalesMinor),
        const SizedBox(height: AppSpacing.md),
        PaymentMethodPieChart(totals: sales.paymentMethodTotals),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Purchasing overview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: 220,
              child: ReportMoneyMetricCard(
                title: 'Net purchases (goods)',
                minor: purchases.netPurchasesMinor,
                subtitle: '${purchases.purchaseCount} received',
              ),
            ),
            SizedBox(
              width: 220,
              child: ReportMoneyMetricCard(
                title: 'Supplier payments',
                minor: purchases.supplierPaymentsMinor,
                subtitle: 'Cash to suppliers',
              ),
            ),
            SizedBox(
              width: 220,
              child: ReportMoneyMetricCard(
                title: 'Outstanding payables',
                minor: snapshot.supplierPayablesMinor,
                subtitle: 'Current ledger balance',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Inventory overview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ReportMetricCard(
              title: 'Active products',
              value: '${inventory.activeProductCount}',
            ),
            ReportMetricCard(
              title: 'Out of stock',
              value: '${inventory.zeroStockCount}',
            ),
            ReportMetricCard(
              title: 'Low stock',
              value: '${inventory.lowStockCount}',
            ),
            if (inventory.stockValueAvailable)
              ReportMoneyMetricCard(
                title: 'Stock value (current cost)',
                minor: inventory.stockValueMinor,
                subtitle: 'Indicative; not COGS',
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Financial overview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ReportMoneyMetricCard(
              title: 'Sales revenue (period)',
              minor: sales.netSalesMinor,
            ),
            metricAvailabilityMoneyCard(
              title: 'Cost of goods sold',
              metric: snapshot.cogs,
            ),
            metricAvailabilityMoneyCard(
              title: 'Gross profit',
              metric: snapshot.grossProfit,
            ),
            metricAvailabilityMoneyCard(
              title: 'Expenses',
              metric: snapshot.expenses,
            ),
            metricAvailabilityMoneyCard(
              title: 'Net profit',
              metric: snapshot.netProfit,
            ),
          ],
        ),
        if (snapshot.topProducts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Top products by revenue',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.topProducts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = snapshot.topProducts[i];
                return ListTile(
                  dense: true,
                  title: Text(p.name),
                  subtitle: Text('Qty: ${p.quantityBase}'),
                  trailing: Text(
                    '${MoneyAmount.formatPkrFromMinor(p.revenueMinor)} PKR',
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
