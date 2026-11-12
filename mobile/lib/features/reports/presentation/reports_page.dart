import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/inventory_providers.dart';
import 'package:pos_mobile/app/providers/purchasing_providers.dart';
import 'package:pos_mobile/app/providers/sales_providers.dart';
import 'package:pos_mobile/app/providers/reporting_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/inventory/presentation/stock_detail_sheet.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';
import 'package:pos_mobile/features/reporting/domain/reporting_models.dart';
import 'package:pos_mobile/features/reporting/presentation/report_charts.dart';
import 'package:pos_mobile/features/reporting/presentation/report_metric_widgets.dart';
import 'package:pos_mobile/features/reporting/presentation/report_period_chips.dart';
import 'package:pos_mobile/features/reporting/presentation/ledger_history_sheet.dart';
import 'package:pos_mobile/features/reporting/presentation/sale_detail_dialog.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CatalogAccessGate(child: _ReportsBody());
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Reports', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          const ReportPeriodChips(),
          const SizedBox(height: AppSpacing.md),
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Sales'),
              Tab(text: 'Purchases'),
              Tab(text: 'Inventory'),
              Tab(text: 'Accounts'),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _SalesReportTab(),
                _PurchasesReportTab(),
                _InventoryReportTab(),
                _AccountsReportTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesReportTab extends ConsumerStatefulWidget {
  const _SalesReportTab();

  @override
  ConsumerState<_SalesReportTab> createState() => _SalesReportTabState();
}

class _SalesReportTabState extends ConsumerState<_SalesReportTab> {
  List<SaleListRow> _sales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final period = ref.read(reportPeriodProvider);
    final rows = await ref
        .read(reportingRepositoryProvider)
        .listCompletedSales(period, limit: 200);
    if (!mounted) {
      return;
    }
    setState(() {
      _sales = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reportPeriodPresetProvider, (_, __) => _reload());
    final metrics = ref.watch(salesPeriodMetricsProvider);
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          metrics.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (m) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    ReportMetricCard(
                      title: 'Sales count',
                      value: '${m.saleCount}',
                    ),
                    ReportMoneyMetricCard(
                      title: 'Gross sales',
                      minor: m.grossSalesMinor,
                    ),
                    ReportMoneyMetricCard(
                      title: 'Net sales',
                      minor: m.netSalesMinor,
                    ),
                    ReportMoneyMetricCard(
                      title: 'Sale returns',
                      minor: m.returnsMinor,
                      subtitle: 'Credit; not cash refunds',
                    ),
                    ReportMoneyMetricCard(
                      title: 'Net after returns',
                      minor: m.netSalesAfterReturnsMinor,
                    ),
                    ReportMoneyMetricCard(
                      title: 'Checkout collections',
                      minor: m.checkoutCollectionsMinor,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DailyTrendBarChart(points: m.dailyNetSalesMinor),
                const SizedBox(height: AppSpacing.md),
                PaymentMethodPieChart(totals: m.paymentMethodTotals),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Sales list', style: Theme.of(context).textTheme.titleMedium),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_sales.isEmpty)
            const Text('No completed sales in this period.')
          else
            ..._sales.map(
              (s) => ListTile(
                title: Text(s.invoiceNumber ?? s.saleNumber),
                subtitle: Text(s.customerName ?? 'Walk-in'),
                trailing: Text(
                  '${MoneyAmount.formatPkrFromMinor(s.totalMinor)} PKR',
                ),
                onTap: () => showSaleDetailDialog(context, ref, s.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _PurchasesReportTab extends ConsumerStatefulWidget {
  const _PurchasesReportTab();

  @override
  ConsumerState<_PurchasesReportTab> createState() =>
      _PurchasesReportTabState();
}

class _PurchasesReportTabState extends ConsumerState<_PurchasesReportTab> {
  PurchasePeriodMetrics? _metrics;
  List<PurchaseListRow> _purchases = [];
  List<SupplierPurchaseTotalRow> _bySupplier = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final period = ref.read(reportPeriodProvider);
    final repo = ref.read(reportingRepositoryProvider);
    final metrics = await repo.purchasePeriodMetrics(period);
    final list = await repo.listReceivedPurchases(period, limit: 200);
    final bySup = await repo.supplierPurchaseTotals(period);
    if (!mounted) {
      return;
    }
    setState(() {
      _metrics = metrics;
      _purchases = list;
      _bySupplier = bySup;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reportPeriodPresetProvider, (_, __) => _reload());
    if (_loading || _metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final m = _metrics!;
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ReportMetricCard(
                title: 'Purchase count',
                value: '${m.purchaseCount}',
              ),
              ReportMoneyMetricCard(
                title: 'Gross purchases',
                minor: m.grossPurchasesMinor,
              ),
              ReportMoneyMetricCard(
                title: 'Purchase returns',
                minor: m.purchaseReturnsMinor,
              ),
              ReportMoneyMetricCard(
                title: 'Net purchases',
                minor: m.netPurchasesMinor,
              ),
              ReportMoneyMetricCard(
                title: 'Supplier payments',
                minor: m.supplierPaymentsMinor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DailyTrendBarChart(
            points: m.dailyNetPurchasesMinor,
            title: 'Daily purchases (received goods)',
            emptyMessage: 'No purchases in this period.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Supplier totals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final row in _bySupplier)
            ListTile(
              title: Text(row.name),
              subtitle: Text('${row.purchaseCount} purchase(s)'),
              trailing: Text(
                '${MoneyAmount.formatPkrFromMinor(row.totalMinor)} PKR',
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Purchase history',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final p in _purchases)
            ListTile(
              title: Text(p.purchaseNumber),
              subtitle: Text(p.supplierName ?? '—'),
              trailing: Text(
                '${MoneyAmount.formatPkrFromMinor(p.totalMinor)} PKR',
              ),
              onTap: () async {
                final purchase = await ref
                    .read(purchaseRepositoryProvider)
                    .getPurchaseById(p.id);
                if (!context.mounted || purchase == null) {
                  return;
                }
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(purchase.purchaseNumber),
                    content: Text(
                      'Total: ${MoneyAmount.formatPkrFromMinor(purchase.totalMinor)} PKR\n'
                      'Paid: ${MoneyAmount.formatPkrFromMinor(purchase.amountPaidMinor)} PKR',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _InventoryReportTab extends ConsumerStatefulWidget {
  const _InventoryReportTab();

  @override
  ConsumerState<_InventoryReportTab> createState() =>
      _InventoryReportTabState();
}

class _InventoryReportTabState extends ConsumerState<_InventoryReportTab> {
  InventoryReportMetrics? _metrics;
  List<InventoryOverviewRow> _stock = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final period = ref.read(reportPeriodProvider);
    final metrics = await ref
        .read(reportingRepositoryProvider)
        .inventoryMetrics(movementSinceMs: period.startMsInclusive);
    final stock = await ref
        .read(inventoryRepositoryProvider)
        .listOverview(limit: 300);
    if (!mounted) {
      return;
    }
    setState(() {
      _metrics = metrics;
      _stock = stock;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reportPeriodPresetProvider, (_, __) => _reload());
    if (_loading || _metrics == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final m = _metrics!;
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ReportMetricCard(
                title: 'Out of stock',
                value: '${m.zeroStockCount}',
              ),
              ReportMetricCard(title: 'Low stock', value: '${m.lowStockCount}'),
              ReportMoneyMetricCard(
                title: 'Stock value (current cost)',
                minor: m.stockValueMinor,
              ),
              ReportMetricCard(
                title: 'Damaged qty (period)',
                value: '${m.damagedQtyBase}',
              ),
              ReportMetricCard(
                title: 'Expired qty (period)',
                value: '${m.expiredQtyBase}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Movement types (period)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final e in m.movementTotalsByType.entries)
            ListTile(
              dense: true,
              title: Text(e.key),
              trailing: Text('${e.value}'),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Stock by product',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final row in _stock)
            ListTile(
              title: Text(row.product.name),
              subtitle: Text(
                'On hand: ${row.quantityOnHandBase} · ${row.status.name}',
              ),
              trailing: Text(
                MoneyAmount.formatPkrFromMinor(
                  row.product.costPriceMinor * row.quantityOnHandBase,
                ),
              ),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (context) => StockDetailSheet(overview: row),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountsReportTab extends ConsumerStatefulWidget {
  const _AccountsReportTab();

  @override
  ConsumerState<_AccountsReportTab> createState() => _AccountsReportTabState();
}

class _AccountsReportTabState extends ConsumerState<_AccountsReportTab> {
  List<CustomerBalanceRow> _customers = [];
  List<SupplierBalanceRow> _suppliers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final repo = ref.read(reportingRepositoryProvider);
    final customers = await repo.customerBalances();
    final suppliers = await repo.supplierBalances();
    if (!mounted) {
      return;
    }
    setState(() {
      _customers = customers;
      _suppliers = suppliers;
      _loading = false;
    });
  }

  Future<void> _pickCustomerLedger(BuildContext context) async {
    final customers = await ref
        .read(customerRepositoryProvider)
        .listCustomers(limit: 200);
    if (!context.mounted || customers.isEmpty) {
      return;
    }
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select customer'),
        children: [
          for (final c in customers)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, c.id),
              child: Text(c.name),
            ),
        ],
      ),
    );
    if (picked == null || !context.mounted) {
      return;
    }
    final name = customers.firstWhere((c) => c.id == picked).name;
    await showLedgerHistorySheet(
      context: context,
      ref: ref,
      party: LedgerHistoryParty.customer,
      partyId: picked,
      partyName: name,
    );
  }

  Future<void> _pickSupplierLedger(BuildContext context) async {
    final suppliers = await ref
        .read(supplierRepositoryProvider)
        .listSuppliers(limit: 200);
    if (!context.mounted || suppliers.isEmpty) {
      return;
    }
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select supplier'),
        children: [
          for (final s in suppliers)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, s.id),
              child: Text(s.name),
            ),
        ],
      ),
    );
    if (picked == null || !context.mounted) {
      return;
    }
    final name = suppliers.firstWhere((s) => s.id == picked).name;
    await showLedgerHistorySheet(
      context: context,
      ref: ref,
      party: LedgerHistoryParty.supplier,
      partyId: picked,
      partyName: name,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          OutlinedButton.icon(
            onPressed: () => _pickCustomerLedger(context),
            icon: const Icon(Icons.history),
            label: const Text('Customer ledger history'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _pickSupplierLedger(context),
            icon: const Icon(Icons.history),
            label: const Text('Supplier ledger history'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Customer receivables',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_customers.isEmpty)
            const Text('No outstanding customer balances.')
          else
            for (final c in _customers)
              ListTile(
                title: Text(c.name),
                subtitle: const Text('Tap for transaction history'),
                trailing: Text(
                  '${MoneyAmount.formatPkrFromMinor(c.outstandingMinor)} PKR',
                ),
                onTap: () => showLedgerHistorySheet(
                  context: context,
                  ref: ref,
                  party: LedgerHistoryParty.customer,
                  partyId: c.customerId,
                  partyName: c.name,
                ),
              ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Supplier payables',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_suppliers.isEmpty)
            const Text('No outstanding supplier balances.')
          else
            for (final s in _suppliers)
              ListTile(
                title: Text(s.name),
                subtitle: const Text('Tap for transaction history'),
                trailing: Text(
                  '${MoneyAmount.formatPkrFromMinor(s.outstandingMinor)} PKR',
                ),
                onTap: () => showLedgerHistorySheet(
                  context: context,
                  ref: ref,
                  party: LedgerHistoryParty.supplier,
                  partyId: s.supplierId,
                  partyName: s.name,
                ),
              ),
        ],
      ),
    );
  }
}
