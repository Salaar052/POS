/// Phase 6 reporting definitions (integer paisa/minor units).
///
/// **Gross sales:** Sum of `sales.subtotal_minor` for COMPLETED sales in period
/// (line subtotals before sale-level discount).
///
/// **Discounts:** Sum of `sales.discount_minor` for completed sales in period.
///
/// **Net sales (revenue):** Sum of `sales.total_minor` for completed sales.
///
/// **Sale returns:** Sum of `sale_returns.total_minor` with return timestamp in period.
/// Not subtracted from gross/discount rows — reported separately; **net after returns**
/// = net sales − returns.
///
/// **Checkout collections:** Sum of `sale_payments.amount_minor` by payment method
/// where payment `created_at_ms` is in period (POS checkout only).
///
/// **Customer account payments:** Ledger credits where `entry_type` is customer payment
/// and `reference_type` is `CUSTOMER_PAYMENT` (excludes checkout-linked ledger rows).
/// Not counted as sales revenue.
///
/// **Purchases (goods value):** Sum of `purchases.total_minor` for RECEIVED purchases
/// with `received_at_ms` in period.
///
/// **Purchase returns:** Sum of completed purchase return totals in period.
///
/// **Supplier payments (cash):** `purchase_payments` in period plus supplier ledger
/// PAYMENT credits with reference `SUPPLIER_PAYMENT` (not purchase value).
///
/// **Receivables / payables:** Current ledger balances (debit − credit), not period-bound.
///
/// **COGS / gross profit / net profit:** **Unavailable** — sale items do not store cost
/// at time of sale; expenses module not implemented.
///
/// **Inventory valuation:** Sum of `quantity_on_hand × products.cost_price_minor` at
/// **current** cost (indicative only, not historical COGS).
abstract final class ReportingDefinitions {
  static const customerPaymentRefType = 'CUSTOMER_PAYMENT';
  static const salePaymentLedgerRef = 'SALE_PAYMENT';
}
