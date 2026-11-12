class MetricAvailability<T> {
  const MetricAvailability.available(this.value) : unavailableReason = null;
  const MetricAvailability.unavailable(this.unavailableReason) : value = null;

  final T? value;
  final String? unavailableReason;

  bool get isAvailable => value != null;
}

class SalesPeriodMetrics {
  const SalesPeriodMetrics({
    required this.saleCount,
    required this.grossSalesMinor,
    required this.discountMinor,
    required this.netSalesMinor,
    required this.returnsMinor,
    required this.checkoutCollectionsMinor,
    required this.customerAccountPaymentsMinor,
    required this.paymentMethodTotals,
    required this.dailyNetSalesMinor,
  });

  final int saleCount;
  final int grossSalesMinor;
  final int discountMinor;
  final int netSalesMinor;
  final int returnsMinor;
  final int checkoutCollectionsMinor;
  final int customerAccountPaymentsMinor;
  final Map<String, int> paymentMethodTotals;
  final List<DailyTotalPoint> dailyNetSalesMinor;

  int get netSalesAfterReturnsMinor => netSalesMinor - returnsMinor;

  int? get averageSaleMinor =>
      saleCount == 0 ? null : netSalesMinor ~/ saleCount;
}

class DailyTotalPoint {
  const DailyTotalPoint({
    required this.dayStartMsUtc,
    required this.label,
    required this.totalMinor,
  });

  final int dayStartMsUtc;
  final String label;
  final int totalMinor;
}

class PurchasePeriodMetrics {
  const PurchasePeriodMetrics({
    required this.purchaseCount,
    required this.grossPurchasesMinor,
    required this.purchaseReturnsMinor,
    required this.supplierPaymentsMinor,
    required this.dailyNetPurchasesMinor,
  });

  final int purchaseCount;
  final int grossPurchasesMinor;
  final int purchaseReturnsMinor;
  final int supplierPaymentsMinor;
  final List<DailyTotalPoint> dailyNetPurchasesMinor;

  int get netPurchasesMinor => grossPurchasesMinor - purchaseReturnsMinor;
}

class InventoryReportMetrics {
  const InventoryReportMetrics({
    required this.activeProductCount,
    required this.zeroStockCount,
    required this.lowStockCount,
    required this.stockValueMinor,
    required this.stockValueAvailable,
    required this.recentMovements,
    required this.movementTotalsByType,
    required this.damagedQtyBase,
    required this.expiredQtyBase,
  });

  final int activeProductCount;
  final int zeroStockCount;
  final int lowStockCount;
  final int stockValueMinor;
  final bool stockValueAvailable;
  final List<StockMovementSummaryRow> recentMovements;
  final Map<String, int> movementTotalsByType;
  final int damagedQtyBase;
  final int expiredQtyBase;
}

class StockMovementSummaryRow {
  const StockMovementSummaryRow({
    required this.id,
    required this.productName,
    required this.movementType,
    required this.quantityBase,
    required this.createdAtMs,
  });

  final String id;
  final String productName;
  final String movementType;
  final int quantityBase;
  final int createdAtMs;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.sales,
    required this.purchases,
    required this.inventory,
    required this.customerReceivablesMinor,
    required this.supplierPayablesMinor,
    required this.cogs,
    required this.grossProfit,
    required this.expenses,
    required this.netProfit,
    required this.topProducts,
  });

  final SalesPeriodMetrics sales;
  final PurchasePeriodMetrics purchases;
  final InventoryReportMetrics inventory;
  final int customerReceivablesMinor;
  final int supplierPayablesMinor;
  final MetricAvailability<int> cogs;
  final MetricAvailability<int> grossProfit;
  final MetricAvailability<int> expenses;
  final MetricAvailability<int> netProfit;
  final List<TopProductRow> topProducts;
}

class TopProductRow {
  const TopProductRow({
    required this.productId,
    required this.name,
    required this.quantityBase,
    required this.revenueMinor,
  });

  final String productId;
  final String name;
  final int quantityBase;
  final int revenueMinor;
}

class CustomerBalanceRow {
  const CustomerBalanceRow({
    required this.customerId,
    required this.name,
    required this.outstandingMinor,
  });

  final String customerId;
  final String name;
  final int outstandingMinor;
}

class SupplierBalanceRow {
  const SupplierBalanceRow({
    required this.supplierId,
    required this.name,
    required this.outstandingMinor,
  });

  final String supplierId;
  final String name;
  final int outstandingMinor;
}

class PurchaseListRow {
  const PurchaseListRow({
    required this.id,
    required this.purchaseNumber,
    required this.supplierName,
    required this.totalMinor,
    required this.receivedAtMs,
  });

  final String id;
  final String purchaseNumber;
  final String? supplierName;
  final int totalMinor;
  final int? receivedAtMs;
}

class SupplierPurchaseTotalRow {
  const SupplierPurchaseTotalRow({
    required this.supplierId,
    required this.name,
    required this.totalMinor,
    required this.purchaseCount,
  });

  final String supplierId;
  final String name;
  final int totalMinor;
  final int purchaseCount;
}

class SaleListRow {
  const SaleListRow({
    required this.id,
    required this.invoiceNumber,
    required this.saleNumber,
    required this.customerName,
    required this.totalMinor,
    required this.completedAtMs,
  });

  final String id;
  final String? invoiceNumber;
  final String saleNumber;
  final String? customerName;
  final int totalMinor;
  final int? completedAtMs;
}

class LedgerHistoryEntry {
  const LedgerHistoryEntry({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.createdAtMs,
    required this.typeLabel,
    required this.referenceLabel,
    required this.debitMinor,
    required this.creditMinor,
    required this.balanceAfterMinor,
    this.linkedSaleId,
    this.linkedPurchaseId,
    this.linkedSaleReturnId,
    this.linkedPurchaseReturnId,
    this.paymentMethod,
    this.notes,
  });

  final String id;
  final String partyId;
  final String partyName;
  final int createdAtMs;
  final String typeLabel;
  final String referenceLabel;
  final int debitMinor;
  final int creditMinor;
  final int balanceAfterMinor;
  final String? linkedSaleId;
  final String? linkedPurchaseId;
  final String? linkedSaleReturnId;
  final String? linkedPurchaseReturnId;
  final String? paymentMethod;
  final String? notes;
}

class LedgerHistoryPage {
  const LedgerHistoryPage({
    required this.entries,
    required this.hasMore,
    required this.nextOffset,
    required this.authoritativeBalanceMinor,
    required this.openingBalanceMinor,
  });

  final List<LedgerHistoryEntry> entries;
  final bool hasMore;
  final int nextOffset;
  final int authoritativeBalanceMinor;
  final int openingBalanceMinor;
}
