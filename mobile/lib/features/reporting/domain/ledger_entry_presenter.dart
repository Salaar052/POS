import 'package:pos_mobile/data/repositories/customer_repository.dart';
import 'package:pos_mobile/data/repositories/purchase_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';

/// Human-readable ledger labels derived from stored entry_type + reference_type.
abstract final class LedgerEntryPresenter {
  static String customerTypeLabel({
    required String entryType,
    required String referenceType,
  }) {
    CustomerLedgerEntryType? type;
    for (final e in CustomerLedgerEntryType.values) {
      if (e.storage == entryType) {
        type = e;
        break;
      }
    }
    return switch (type) {
      CustomerLedgerEntryType.saleReceivable => 'Sale on account',
      CustomerLedgerEntryType.customerPayment =>
        referenceType == SalesRepository.refTypeSalePayment
            ? 'Checkout payment (on account)'
            : 'Customer payment',
      CustomerLedgerEntryType.saleReturn => 'Sale return credit',
      CustomerLedgerEntryType.adjustment => 'Adjustment',
      null => entryType,
    };
  }

  static String supplierTypeLabel({
    required String entryType,
    required String referenceType,
  }) {
    SupplierLedgerEntryType? type;
    for (final e in SupplierLedgerEntryType.values) {
      if (e.storage == entryType) {
        type = e;
        break;
      }
    }
    return switch (type) {
      SupplierLedgerEntryType.purchasePayable => 'Purchase payable',
      SupplierLedgerEntryType.payment => 'Supplier payment',
      SupplierLedgerEntryType.purchaseReturn => 'Purchase return',
      SupplierLedgerEntryType.adjustment => 'Adjustment',
      SupplierLedgerEntryType.reversal => 'Reversal',
      null => entryType,
    };
  }

  static bool customerPaymentCountsAsAccountCollection({
    required String entryType,
    required String referenceType,
  }) {
    return entryType == CustomerLedgerEntryType.customerPayment.storage &&
        referenceType == CustomerRepository.refTypeCustomerPayment;
  }

  static String? customerLinkedSaleId({
    required String referenceType,
    required String referenceId,
  }) {
    if (referenceType == SalesRepository.refTypeSaleCheckout) {
      final idx = referenceId.indexOf(':');
      return idx > 0 ? referenceId.substring(0, idx) : null;
    }
  }

  static String? customerLinkedReturnId({
    required String referenceType,
    required String referenceId,
  }) {
    if (referenceType == SalesRepository.refTypeSaleReturn) {
      return referenceId;
    }
    return null;
  }

  static String? supplierLinkedPurchaseId({
    required String referenceType,
    required String referenceId,
  }) {
    if (referenceType == PurchaseRepository.refTypePurchaseReceive) {
      final idx = referenceId.indexOf(':');
      return idx > 0 ? referenceId.substring(0, idx) : null;
    }
    return null;
  }

  static String? supplierLinkedReturnId({
    required String referenceType,
    required String referenceId,
  }) {
    if (referenceType == PurchaseRepository.refTypePurchaseReturn) {
      return referenceId;
    }
    return null;
  }
}
