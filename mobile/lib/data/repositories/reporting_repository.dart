import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';
import 'package:pos_mobile/features/reporting/domain/pakistan_time.dart';
import 'package:pos_mobile/features/reporting/domain/report_period.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/features/reporting/domain/ledger_entry_presenter.dart';
import 'package:pos_mobile/features/reporting/domain/reporting_definitions.dart';
import 'package:pos_mobile/features/reporting/domain/reporting_models.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

class ReportingRepository {
  ReportingRepository(this._runner);

  final DatabaseRunner _runner;

  Future<DashboardSnapshot> dashboardSnapshot(ReportPeriod period) async {
    final sales = await salesPeriodMetrics(period);
    final purchases = await purchasePeriodMetrics(period);
    final inventory = await inventoryMetrics(
      movementSinceMs: period.startMsInclusive,
    );
    final receivables = await customerReceivablesMinor();
    final payables = await supplierPayablesMinor();
    final top = await topProductsByRevenue(period, limit: 5);
    return DashboardSnapshot(
      sales: sales,
      purchases: purchases,
      inventory: inventory,
      customerReceivablesMinor: receivables,
      supplierPayablesMinor: payables,
      cogs: const MetricAvailability.unavailable(
        'Sale lines do not store historical cost; COGS deferred.',
      ),
      grossProfit: const MetricAvailability.unavailable(
        'Requires historical COGS per sale line.',
      ),
      expenses: const MetricAvailability.unavailable(
        'Expense tracking is not implemented.',
      ),
      netProfit: const MetricAvailability.unavailable(
        'Requires expenses and accurate COGS.',
      ),
      topProducts: top,
    );
  }

  Future<SalesPeriodMetrics> salesPeriodMetrics(ReportPeriod period) async {
    final start = period.startMsInclusive;
    final end = period.endMsExclusive;
    final completed = SaleStatus.completed.storage;

    final salesAgg = await _runner.database
        .customSelect(
          '''
SELECT
  COUNT(*) AS sale_count,
  COALESCE(SUM(subtotal_minor), 0) AS gross_minor,
  COALESCE(SUM(discount_minor), 0) AS discount_minor,
  COALESCE(SUM(total_minor), 0) AS net_minor
FROM sales
WHERE status = ?1
  AND completed_at_ms IS NOT NULL
  AND completed_at_ms >= ?2
  AND completed_at_ms < ?3
''',
          variables: [
            Variable.withString(completed),
            Variable.withInt(start),
            Variable.withInt(end),
          ],
          readsFrom: {_runner.database.sales},
        )
        .getSingle();

    final returnsAgg = await _runner.database
        .customSelect(
          '''
SELECT COALESCE(SUM(total_minor), 0) AS returns_minor
FROM sale_returns
WHERE completed_at_ms IS NOT NULL
  AND completed_at_ms >= ?1
  AND completed_at_ms < ?2
''',
          variables: [Variable.withInt(start), Variable.withInt(end)],
          readsFrom: {_runner.database.saleReturns},
        )
        .getSingle();

    final checkoutAgg = await _runner.database
        .customSelect(
          '''
SELECT COALESCE(SUM(amount_minor), 0) AS total_minor
FROM sale_payments
WHERE created_at_ms >= ?1 AND created_at_ms < ?2
''',
          variables: [Variable.withInt(start), Variable.withInt(end)],
          readsFrom: {_runner.database.salePayments},
        )
        .getSingle();

    final customerPaymentsAgg = await _runner.database
        .customSelect(
          '''
SELECT COALESCE(SUM(credit_minor), 0) AS total_minor
FROM customer_ledger_entries
WHERE entry_type = ?1
  AND reference_type = ?2
  AND created_at_ms >= ?3
  AND created_at_ms < ?4
''',
          variables: [
            Variable.withString(
              CustomerLedgerEntryType.customerPayment.storage,
            ),
            Variable.withString(ReportingDefinitions.customerPaymentRefType),
            Variable.withInt(start),
            Variable.withInt(end),
          ],
          readsFrom: {_runner.database.customerLedgerEntries},
        )
        .getSingle();

    final methodRows = await _runner.database
        .customSelect(
          '''
SELECT payment_method, COALESCE(SUM(amount_minor), 0) AS total_minor
FROM sale_payments
WHERE created_at_ms >= ?1 AND created_at_ms < ?2
GROUP BY payment_method
''',
          variables: [Variable.withInt(start), Variable.withInt(end)],
          readsFrom: {_runner.database.salePayments},
        )
        .get();

    final methods = <String, int>{};
    for (final row in methodRows) {
      methods[row.data['payment_method'] as String] =
          row.data['total_minor'] as int;
    }

    final daily = await _dailySaleTotals(start, end);

    return SalesPeriodMetrics(
      saleCount: salesAgg.data['sale_count'] as int,
      grossSalesMinor: salesAgg.data['gross_minor'] as int,
      discountMinor: salesAgg.data['discount_minor'] as int,
      netSalesMinor: salesAgg.data['net_minor'] as int,
      returnsMinor: returnsAgg.data['returns_minor'] as int,
      checkoutCollectionsMinor: checkoutAgg.data['total_minor'] as int,
      customerAccountPaymentsMinor:
          customerPaymentsAgg.data['total_minor'] as int,
      paymentMethodTotals: methods,
      dailyNetSalesMinor: daily,
    );
  }

  Future<List<DailyTotalPoint>> _dailySaleTotals(int start, int end) async {
    final rows = await _runner.database
        .customSelect(
          '''
SELECT completed_at_ms, total_minor
FROM sales
WHERE status = ?1
  AND completed_at_ms IS NOT NULL
  AND completed_at_ms >= ?2
  AND completed_at_ms < ?3
''',
          variables: [
            Variable.withString(SaleStatus.completed.storage),
            Variable.withInt(start),
            Variable.withInt(end),
          ],
          readsFrom: {_runner.database.sales},
        )
        .get();

    final buckets = <int, int>{};
    for (final row in rows) {
      final completedMs = row.data['completed_at_ms'] as int;
      final total = row.data['total_minor'] as int;
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(completedMs, isUtc: true),
      );
      final dayStart = PakistanTime.dayStartMsUtc(
        year: ymd.year,
        month: ymd.month,
        day: ymd.day,
      );
      buckets[dayStart] = (buckets[dayStart] ?? 0) + total;
    }

    final points =
        buckets.entries
            .map(
              (e) => DailyTotalPoint(
                dayStartMsUtc: e.key,
                label: _dayLabel(e.key),
                totalMinor: e.value,
              ),
            )
            .toList()
          ..sort((a, b) => a.dayStartMsUtc.compareTo(b.dayStartMsUtc));
    return points;
  }

  String _dayLabel(int dayStartMsUtc) {
    final pk = DateTime.fromMillisecondsSinceEpoch(
      dayStartMsUtc,
      isUtc: true,
    ).add(PakistanTime.offset);
    return '${pk.month}/${pk.day}';
  }

  Future<PurchasePeriodMetrics> purchasePeriodMetrics(
    ReportPeriod period,
  ) async {
    final start = period.startMsInclusive;
    final end = period.endMsExclusive;
    final received = PurchaseStatus.received.storage;

    final purchaseAgg = await _runner.database
        .customSelect(
          '''
SELECT COUNT(*) AS cnt, COALESCE(SUM(total_minor), 0) AS total_minor
FROM purchases
WHERE status = ?1
  AND received_at_ms IS NOT NULL
  AND received_at_ms >= ?2
  AND received_at_ms < ?3
''',
          variables: [
            Variable.withString(received),
            Variable.withInt(start),
            Variable.withInt(end),
          ],
          readsFrom: {_runner.database.purchases},
        )
        .getSingle();

    final returnAgg = await _runner.database
        .customSelect(
          '''
SELECT COALESCE(SUM(total_minor), 0) AS total_minor
FROM purchase_returns
WHERE status = ?1
  AND completed_at_ms IS NOT NULL
  AND completed_at_ms >= ?2
  AND completed_at_ms < ?3
''',
          variables: [
            Variable.withString(PurchaseReturnStatus.completed.storage),
            Variable.withInt(start),
            Variable.withInt(end),
          ],
          readsFrom: {_runner.database.purchaseReturns},
        )
        .getSingle();

    final payAgg = await _runner.database
        .customSelect(
          '''
SELECT COALESCE(SUM(amount_minor), 0) AS total_minor
FROM purchase_payments
WHERE created_at_ms >= ?1 AND created_at_ms < ?2
''',
          variables: [Variable.withInt(start), Variable.withInt(end)],
          readsFrom: {_runner.database.purchasePayments},
        )
        .getSingle();

    final daily = await _dailyPurchaseTotals(start, end);

    return PurchasePeriodMetrics(
      purchaseCount: purchaseAgg.data['cnt'] as int,
      grossPurchasesMinor: purchaseAgg.data['total_minor'] as int,
      purchaseReturnsMinor: returnAgg.data['total_minor'] as int,
      supplierPaymentsMinor: payAgg.data['total_minor'] as int,
      dailyNetPurchasesMinor: daily,
    );
  }

  Future<List<DailyTotalPoint>> _dailyPurchaseTotals(int start, int end) async {
    final rows = await _runner.database
        .customSelect(
          '''
SELECT received_at_ms, total_minor
FROM purchases
WHERE status = ?1
  AND received_at_ms IS NOT NULL
  AND received_at_ms >= ?2
  AND received_at_ms < ?3
''',
          variables: [
            Variable.withString(PurchaseStatus.received.storage),
            Variable.withInt(start),
            Variable.withInt(end),
          ],
          readsFrom: {_runner.database.purchases},
        )
        .get();

    final buckets = <int, int>{};
    for (final row in rows) {
      final ms = row.data['received_at_ms'] as int;
      final total = row.data['total_minor'] as int;
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
      );
      final dayStart = PakistanTime.dayStartMsUtc(
        year: ymd.year,
        month: ymd.month,
        day: ymd.day,
      );
      buckets[dayStart] = (buckets[dayStart] ?? 0) + total;
    }
    return buckets.entries
        .map(
          (e) => DailyTotalPoint(
            dayStartMsUtc: e.key,
            label: _dayLabel(e.key),
            totalMinor: e.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.dayStartMsUtc.compareTo(b.dayStartMsUtc));
  }

  Future<InventoryReportMetrics> inventoryMetrics({
    int? movementSinceMs,
  }) async {
    final activeAgg = await _runner.database
        .customSelect(
          '''
SELECT COUNT(*) AS cnt
FROM products
WHERE is_active = 1 AND archived_at_ms IS NULL
''',
          readsFrom: {_runner.database.products},
        )
        .getSingle();

    final stockAgg = await _runner.database
        .customSelect(
          '''
SELECT
  SUM(CASE WHEN COALESCE(b.quantity_on_hand_base, 0) <= 0 THEN 1 ELSE 0 END) AS zero_cnt,
  SUM(CASE WHEN b.minimum_stock_base IS NOT NULL
    AND COALESCE(b.quantity_on_hand_base, 0) > 0
    AND COALESCE(b.quantity_on_hand_base, 0) <= b.minimum_stock_base
    THEN 1 ELSE 0 END) AS low_cnt,
  COALESCE(SUM(COALESCE(b.quantity_on_hand_base, 0) * p.cost_price_minor), 0) AS stock_value
FROM products p
LEFT JOIN inventory_balances b ON b.product_id = p.id
WHERE p.is_active = 1 AND p.archived_at_ms IS NULL
''',
          readsFrom: {
            _runner.database.products,
            _runner.database.inventoryBalances,
          },
        )
        .getSingle();

    final since = movementSinceMs ?? 0;
    final moveTypes = await _runner.database
        .customSelect(
          '''
SELECT movement_type, COALESCE(SUM(quantity_base), 0) AS qty
FROM stock_movements
WHERE created_at_ms >= ?1
GROUP BY movement_type
''',
          variables: [Variable.withInt(since)],
          readsFrom: {_runner.database.stockMovements},
        )
        .get();

    final typeTotals = <String, int>{};
    var damaged = 0;
    var expired = 0;
    for (final row in moveTypes) {
      final type = row.data['movement_type'] as String;
      final qty = row.data['qty'] as int;
      typeTotals[type] = qty;
      if (type == StockMovementType.damage.storageValue) {
        damaged = qty;
      }
      if (type == StockMovementType.expired.storageValue) {
        expired = qty;
      }
    }

    final recent = await _runner.database
        .customSelect(
          '''
SELECT sm.id, sm.movement_type, sm.quantity_base, sm.created_at_ms, p.name
FROM stock_movements sm
INNER JOIN products p ON p.id = sm.product_id
ORDER BY sm.created_at_ms DESC
LIMIT 8
''',
          readsFrom: {
            _runner.database.stockMovements,
            _runner.database.products,
          },
        )
        .get();

    final recentRows = recent
        .map(
          (r) => StockMovementSummaryRow(
            id: r.data['id'] as String,
            productName: r.data['name'] as String,
            movementType: r.data['movement_type'] as String,
            quantityBase: r.data['quantity_base'] as int,
            createdAtMs: r.data['created_at_ms'] as int,
          ),
        )
        .toList();

    return InventoryReportMetrics(
      activeProductCount: activeAgg.data['cnt'] as int,
      zeroStockCount: stockAgg.data['zero_cnt'] as int? ?? 0,
      lowStockCount: stockAgg.data['low_cnt'] as int? ?? 0,
      stockValueMinor: stockAgg.data['stock_value'] as int? ?? 0,
      stockValueAvailable: true,
      recentMovements: recentRows,
      movementTotalsByType: typeTotals,
      damagedQtyBase: damaged,
      expiredQtyBase: expired,
    );
  }

  Future<int> customerReceivablesMinor() async {
    final row = await _runner.database
        .customSelect(
          '''
SELECT
  COALESCE(SUM(debit_minor), 0) - COALESCE(SUM(credit_minor), 0) AS outstanding
FROM customer_ledger_entries
''',
          readsFrom: {_runner.database.customerLedgerEntries},
        )
        .getSingle();
    final v = row.data['outstanding'] as int;
    return v < 0 ? 0 : v;
  }

  Future<int> supplierPayablesMinor() async {
    final row = await _runner.database
        .customSelect(
          '''
SELECT
  COALESCE(SUM(debit_minor), 0) - COALESCE(SUM(credit_minor), 0) AS outstanding
FROM supplier_ledger_entries
''',
          readsFrom: {_runner.database.supplierLedgerEntries},
        )
        .getSingle();
    final v = row.data['outstanding'] as int;
    return v < 0 ? 0 : v;
  }

  Future<List<TopProductRow>> topProductsByRevenue(
    ReportPeriod period, {
    int limit = 10,
  }) async {
    final rows = await _runner.database
        .customSelect(
          '''
SELECT
  si.product_id AS product_id,
  si.product_name_snapshot AS name,
  COALESCE(SUM(si.quantity_base), 0) AS qty,
  COALESCE(SUM(si.line_total_minor), 0) AS revenue
FROM sale_items si
INNER JOIN sales s ON s.id = si.sale_id
WHERE s.status = ?1
  AND s.completed_at_ms IS NOT NULL
  AND s.completed_at_ms >= ?2
  AND s.completed_at_ms < ?3
GROUP BY si.product_id, si.product_name_snapshot
ORDER BY revenue DESC
LIMIT ?4
''',
          variables: [
            Variable.withString(SaleStatus.completed.storage),
            Variable.withInt(period.startMsInclusive),
            Variable.withInt(period.endMsExclusive),
            Variable.withInt(limit),
          ],
          readsFrom: {_runner.database.saleItems, _runner.database.sales},
        )
        .get();

    return rows
        .map(
          (r) => TopProductRow(
            productId: r.data['product_id'] as String,
            name: r.data['name'] as String,
            quantityBase: r.data['qty'] as int,
            revenueMinor: r.data['revenue'] as int,
          ),
        )
        .toList();
  }

  Future<List<SaleListRow>> listCompletedSales(
    ReportPeriod period, {
    String? customerId,
    int limit = 100,
  }) async {
    final vars = <Variable>[
      Variable.withString(SaleStatus.completed.storage),
      Variable.withInt(period.startMsInclusive),
      Variable.withInt(period.endMsExclusive),
    ];
    final sql = customerId == null
        ? '''
SELECT id, invoice_number, sale_number, customer_name_snapshot, total_minor, completed_at_ms
FROM sales
WHERE status = ?1
  AND completed_at_ms IS NOT NULL
  AND completed_at_ms >= ?2
  AND completed_at_ms < ?3
ORDER BY completed_at_ms DESC
LIMIT ?4
'''
        : '''
SELECT id, invoice_number, sale_number, customer_name_snapshot, total_minor, completed_at_ms
FROM sales
WHERE status = ?1
  AND completed_at_ms IS NOT NULL
  AND completed_at_ms >= ?2
  AND completed_at_ms < ?3
  AND customer_id = ?4
ORDER BY completed_at_ms DESC
LIMIT ?5
''';
    if (customerId != null) {
      vars.add(Variable.withString(customerId));
    }
    vars.add(Variable.withInt(limit));

    final rows = await _runner.database
        .customSelect(sql, variables: vars, readsFrom: {_runner.database.sales})
        .get();

    return rows
        .map(
          (r) => SaleListRow(
            id: r.data['id'] as String,
            invoiceNumber: r.data['invoice_number'] as String?,
            saleNumber: r.data['sale_number'] as String,
            customerName: r.data['customer_name_snapshot'] as String?,
            totalMinor: r.data['total_minor'] as int,
            completedAtMs: r.data['completed_at_ms'] as int?,
          ),
        )
        .toList();
  }

  Future<List<CustomerBalanceRow>> customerBalances() async {
    final rows = await _runner.database
        .customSelect(
          '''
SELECT
  c.id,
  c.name,
  COALESCE(SUM(e.debit_minor), 0) - COALESCE(SUM(e.credit_minor), 0) AS outstanding
FROM customers c
LEFT JOIN customer_ledger_entries e ON e.customer_id = c.id
WHERE c.is_active = 1 AND c.archived_at_ms IS NULL
GROUP BY c.id, c.name
HAVING outstanding > 0
ORDER BY outstanding DESC
''',
          readsFrom: {
            _runner.database.customers,
            _runner.database.customerLedgerEntries,
          },
        )
        .get();

    return rows
        .map(
          (r) => CustomerBalanceRow(
            customerId: r.data['id'] as String,
            name: r.data['name'] as String,
            outstandingMinor: r.data['outstanding'] as int,
          ),
        )
        .toList();
  }

  Future<List<PurchaseListRow>> listReceivedPurchases(
    ReportPeriod period, {
    int limit = 100,
  }) async {
    final rows = await _runner.database
        .customSelect(
          '''
SELECT p.id, p.purchase_number, s.name AS supplier_name, p.total_minor, p.received_at_ms
FROM purchases p
LEFT JOIN suppliers s ON s.id = p.supplier_id
WHERE p.status = ?1
  AND p.received_at_ms IS NOT NULL
  AND p.received_at_ms >= ?2
  AND p.received_at_ms < ?3
ORDER BY p.received_at_ms DESC
LIMIT ?4
''',
          variables: [
            Variable.withString(PurchaseStatus.received.storage),
            Variable.withInt(period.startMsInclusive),
            Variable.withInt(period.endMsExclusive),
            Variable.withInt(limit),
          ],
          readsFrom: {_runner.database.purchases, _runner.database.suppliers},
        )
        .get();

    return rows
        .map(
          (r) => PurchaseListRow(
            id: r.data['id'] as String,
            purchaseNumber: r.data['purchase_number'] as String,
            supplierName: r.data['supplier_name'] as String?,
            totalMinor: r.data['total_minor'] as int,
            receivedAtMs: r.data['received_at_ms'] as int?,
          ),
        )
        .toList();
  }

  Future<List<SupplierPurchaseTotalRow>> supplierPurchaseTotals(
    ReportPeriod period, {
    int limit = 50,
  }) async {
    final rows = await _runner.database
        .customSelect(
          '''
SELECT
  p.supplier_id AS supplier_id,
  s.name AS name,
  COUNT(*) AS cnt,
  COALESCE(SUM(p.total_minor), 0) AS total_minor
FROM purchases p
INNER JOIN suppliers s ON s.id = p.supplier_id
WHERE p.status = ?1
  AND p.received_at_ms IS NOT NULL
  AND p.received_at_ms >= ?2
  AND p.received_at_ms < ?3
GROUP BY p.supplier_id, s.name
ORDER BY total_minor DESC
LIMIT ?4
''',
          variables: [
            Variable.withString(PurchaseStatus.received.storage),
            Variable.withInt(period.startMsInclusive),
            Variable.withInt(period.endMsExclusive),
            Variable.withInt(limit),
          ],
          readsFrom: {_runner.database.purchases, _runner.database.suppliers},
        )
        .get();

    return rows
        .map(
          (r) => SupplierPurchaseTotalRow(
            supplierId: r.data['supplier_id'] as String,
            name: r.data['name'] as String,
            purchaseCount: r.data['cnt'] as int,
            totalMinor: r.data['total_minor'] as int,
          ),
        )
        .toList();
  }

  Future<List<SupplierBalanceRow>> supplierBalances() async {
    final rows = await _runner.database
        .customSelect(
          '''
SELECT
  s.id,
  s.name,
  COALESCE(SUM(e.debit_minor), 0) - COALESCE(SUM(e.credit_minor), 0) AS outstanding
FROM suppliers s
LEFT JOIN supplier_ledger_entries e ON e.supplier_id = s.id
WHERE s.is_active = 1 AND s.archived_at_ms IS NULL
GROUP BY s.id, s.name
HAVING outstanding > 0
ORDER BY outstanding DESC
''',
          readsFrom: {
            _runner.database.suppliers,
            _runner.database.supplierLedgerEntries,
          },
        )
        .get();

    return rows
        .map(
          (r) => SupplierBalanceRow(
            supplierId: r.data['id'] as String,
            name: r.data['name'] as String,
            outstandingMinor: r.data['outstanding'] as int,
          ),
        )
        .toList();
  }

  Future<LedgerHistoryPage> customerLedgerHistory({
    required String customerId,
    required ReportPeriod period,
    int limit = 50,
    int offset = 0,
  }) async {
    return _ledgerHistory(
      period: period,
      limit: limit,
      offset: offset,
      partyId: customerId,
      isCustomer: true,
    );
  }

  Future<LedgerHistoryPage> supplierLedgerHistory({
    required String supplierId,
    required ReportPeriod period,
    int limit = 50,
    int offset = 0,
  }) async {
    return _ledgerHistory(
      period: period,
      limit: limit,
      offset: offset,
      partyId: supplierId,
      isCustomer: false,
    );
  }

  Future<int> _ledgerOpeningBalance({
    required bool isCustomer,
    required String partyId,
    required int beforeMs,
  }) async {
    if (isCustomer) {
      final row = await _runner.database
          .customSelect(
            '''
SELECT COALESCE(SUM(debit_minor), 0) - COALESCE(SUM(credit_minor), 0) AS bal
FROM customer_ledger_entries
WHERE customer_id = ?1 AND created_at_ms < ?2
''',
            variables: [
              Variable.withString(partyId),
              Variable.withInt(beforeMs),
            ],
            readsFrom: {_runner.database.customerLedgerEntries},
          )
          .getSingle();
      return row.data['bal'] as int;
    }
    final row = await _runner.database
        .customSelect(
          '''
SELECT COALESCE(SUM(debit_minor), 0) - COALESCE(SUM(credit_minor), 0) AS bal
FROM supplier_ledger_entries
WHERE supplier_id = ?1 AND created_at_ms < ?2
''',
          variables: [Variable.withString(partyId), Variable.withInt(beforeMs)],
          readsFrom: {_runner.database.supplierLedgerEntries},
        )
        .getSingle();
    return row.data['bal'] as int;
  }

  Future<int> _authoritativeBalance({
    required bool isCustomer,
    required String partyId,
  }) async {
    if (isCustomer) {
      final row = await _runner.database
          .customSelect(
            '''
SELECT COALESCE(SUM(debit_minor), 0) - COALESCE(SUM(credit_minor), 0) AS bal
FROM customer_ledger_entries WHERE customer_id = ?1
''',
            variables: [Variable.withString(partyId)],
            readsFrom: {_runner.database.customerLedgerEntries},
          )
          .getSingle();
      return row.data['bal'] as int;
    }
    final row = await _runner.database
        .customSelect(
          '''
SELECT COALESCE(SUM(debit_minor), 0) - COALESCE(SUM(credit_minor), 0) AS bal
FROM supplier_ledger_entries WHERE supplier_id = ?1
''',
          variables: [Variable.withString(partyId)],
          readsFrom: {_runner.database.supplierLedgerEntries},
        )
        .getSingle();
    return row.data['bal'] as int;
  }

  Future<LedgerHistoryPage> _ledgerHistory({
    required ReportPeriod period,
    required int limit,
    required int offset,
    required String partyId,
    required bool isCustomer,
  }) async {
    final start = period.startMsInclusive;
    final end = period.endMsExclusive;
    final opening = await _ledgerOpeningBalance(
      isCustomer: isCustomer,
      partyId: partyId,
      beforeMs: start,
    );
    final authoritative = await _authoritativeBalance(
      isCustomer: isCustomer,
      partyId: partyId,
    );

    final partyName = await _partyName(
      isCustomer: isCustomer,
      partyId: partyId,
    );

    final countRow = isCustomer
        ? await _runner.database
              .customSelect(
                '''
SELECT COUNT(*) AS cnt FROM customer_ledger_entries
WHERE customer_id = ?1 AND created_at_ms >= ?2 AND created_at_ms < ?3
''',
                variables: [
                  Variable.withString(partyId),
                  Variable.withInt(start),
                  Variable.withInt(end),
                ],
                readsFrom: {_runner.database.customerLedgerEntries},
              )
              .getSingle()
        : await _runner.database
              .customSelect(
                '''
SELECT COUNT(*) AS cnt FROM supplier_ledger_entries
WHERE supplier_id = ?1 AND created_at_ms >= ?2 AND created_at_ms < ?3
''',
                variables: [
                  Variable.withString(partyId),
                  Variable.withInt(start),
                  Variable.withInt(end),
                ],
                readsFrom: {_runner.database.supplierLedgerEntries},
              )
              .getSingle();
    final totalInPeriod = countRow.data['cnt'] as int;

    final rows = isCustomer
        ? await _runner.database
              .customSelect(
                '''
SELECT id, customer_id, entry_type, debit_minor, credit_minor, reference_type,
       reference_id, payment_method, reference_number, notes, created_at_ms
FROM customer_ledger_entries
WHERE customer_id = ?1 AND created_at_ms >= ?2 AND created_at_ms < ?3
ORDER BY created_at_ms ASC, id ASC
LIMIT ?4 OFFSET ?5
''',
                variables: [
                  Variable.withString(partyId),
                  Variable.withInt(start),
                  Variable.withInt(end),
                  Variable.withInt(limit),
                  Variable.withInt(offset),
                ],
                readsFrom: {_runner.database.customerLedgerEntries},
              )
              .get()
        : await _runner.database
              .customSelect(
                '''
SELECT id, supplier_id, entry_type, debit_minor, credit_minor, reference_type,
       reference_id, notes, created_at_ms
FROM supplier_ledger_entries
WHERE supplier_id = ?1 AND created_at_ms >= ?2 AND created_at_ms < ?3
ORDER BY created_at_ms ASC, id ASC
LIMIT ?4 OFFSET ?5
''',
                variables: [
                  Variable.withString(partyId),
                  Variable.withInt(start),
                  Variable.withInt(end),
                  Variable.withInt(limit),
                  Variable.withInt(offset),
                ],
                readsFrom: {_runner.database.supplierLedgerEntries},
              )
              .get();

    // Running balance requires entries from period start through this page.
    var running = opening;
    if (offset > 0) {
      final skippedRows = isCustomer
          ? await _runner.database
                .customSelect(
                  '''
SELECT debit_minor, credit_minor FROM customer_ledger_entries
WHERE customer_id = ?1 AND created_at_ms >= ?2 AND created_at_ms < ?3
ORDER BY created_at_ms ASC, id ASC
LIMIT ?4
''',
                  variables: [
                    Variable.withString(partyId),
                    Variable.withInt(start),
                    Variable.withInt(end),
                    Variable.withInt(offset),
                  ],
                  readsFrom: {_runner.database.customerLedgerEntries},
                )
                .get()
          : await _runner.database
                .customSelect(
                  '''
SELECT debit_minor, credit_minor FROM supplier_ledger_entries
WHERE supplier_id = ?1 AND created_at_ms >= ?2 AND created_at_ms < ?3
ORDER BY created_at_ms ASC, id ASC
LIMIT ?4
''',
                  variables: [
                    Variable.withString(partyId),
                    Variable.withInt(start),
                    Variable.withInt(end),
                    Variable.withInt(offset),
                  ],
                  readsFrom: {_runner.database.supplierLedgerEntries},
                )
                .get();
      for (final s in skippedRows) {
        running +=
            (s.data['debit_minor'] as int) - (s.data['credit_minor'] as int);
      }
    }

    final built = <LedgerHistoryEntry>[];
    for (final row in rows) {
      final debit = row.data['debit_minor'] as int;
      final credit = row.data['credit_minor'] as int;
      running += debit - credit;
      final entryType = row.data['entry_type'] as String;
      final referenceType = row.data['reference_type'] as String;
      final referenceId = row.data['reference_id'] as String;
      final notes = row.data['notes'] as String?;
      final refNumber = isCustomer
          ? row.data['reference_number'] as String?
          : null;
      final paymentMethod = isCustomer
          ? row.data['payment_method'] as String?
          : null;

      String typeLabel;
      String? linkedSaleId;
      String? linkedPurchaseId;
      String? linkedSaleReturnId;
      String? linkedPurchaseReturnId;

      if (isCustomer) {
        typeLabel = LedgerEntryPresenter.customerTypeLabel(
          entryType: entryType,
          referenceType: referenceType,
        );
        linkedSaleId = LedgerEntryPresenter.customerLinkedSaleId(
          referenceType: referenceType,
          referenceId: referenceId,
        );
        linkedSaleReturnId = LedgerEntryPresenter.customerLinkedReturnId(
          referenceType: referenceType,
          referenceId: referenceId,
        );
        if (referenceType == SalesRepository.refTypeSalePayment) {
          linkedSaleId ??= await _saleIdForPaymentKey(referenceId);
        }
        if (linkedSaleReturnId != null) {
          linkedSaleId ??= await _saleIdForReturn(linkedSaleReturnId);
        }
      } else {
        typeLabel = LedgerEntryPresenter.supplierTypeLabel(
          entryType: entryType,
          referenceType: referenceType,
        );
        linkedPurchaseId = LedgerEntryPresenter.supplierLinkedPurchaseId(
          referenceType: referenceType,
          referenceId: referenceId,
        );
        linkedPurchaseReturnId = LedgerEntryPresenter.supplierLinkedReturnId(
          referenceType: referenceType,
          referenceId: referenceId,
        );
        if (linkedPurchaseReturnId != null) {
          linkedPurchaseId ??= await _purchaseIdForReturn(
            linkedPurchaseReturnId,
          );
        }
      }

      final referenceLabel = notes ?? refNumber ?? referenceId;

      built.add(
        LedgerHistoryEntry(
          id: row.data['id'] as String,
          partyId: partyId,
          partyName: partyName,
          createdAtMs: row.data['created_at_ms'] as int,
          typeLabel: typeLabel,
          referenceLabel: referenceLabel,
          debitMinor: debit,
          creditMinor: credit,
          balanceAfterMinor: running,
          linkedSaleId: linkedSaleId,
          linkedPurchaseId: linkedPurchaseId,
          linkedSaleReturnId: linkedSaleReturnId,
          linkedPurchaseReturnId: linkedPurchaseReturnId,
          paymentMethod: paymentMethod,
          notes: notes,
        ),
      );
    }

    final display = built.reversed.toList();
    final hasMore = offset + rows.length < totalInPeriod;

    return LedgerHistoryPage(
      entries: display,
      hasMore: hasMore,
      nextOffset: offset + rows.length,
      authoritativeBalanceMinor: authoritative,
      openingBalanceMinor: opening,
    );
  }

  Future<String> _partyName({
    required bool isCustomer,
    required String partyId,
  }) async {
    if (isCustomer) {
      final row = await (_runner.database.select(
        _runner.database.customers,
      )..where((t) => t.id.equals(partyId))).getSingleOrNull();
      return row?.name ?? partyId;
    }
    final row = await (_runner.database.select(
      _runner.database.suppliers,
    )..where((t) => t.id.equals(partyId))).getSingleOrNull();
    return row?.name ?? partyId;
  }

  Future<String?> _saleIdForReturn(String returnId) async {
    final row = await (_runner.database.select(
      _runner.database.saleReturns,
    )..where((t) => t.id.equals(returnId))).getSingleOrNull();
    return row?.saleId;
  }

  Future<String?> _saleIdForPaymentKey(String idempotencyKey) async {
    final row = await (_runner.database.select(
      _runner.database.salePayments,
    )..where((t) => t.idempotencyKey.equals(idempotencyKey))).getSingleOrNull();
    return row?.saleId;
  }

  Future<String?> _purchaseIdForReturn(String returnId) async {
    final row = await (_runner.database.select(
      _runner.database.purchaseReturns,
    )..where((t) => t.id.equals(returnId))).getSingleOrNull();
    return row?.purchaseId;
  }
}
