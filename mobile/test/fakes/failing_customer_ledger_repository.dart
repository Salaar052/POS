import 'package:pos_mobile/data/repositories/customer_ledger_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';

class FailingCustomerLedgerRepository extends CustomerLedgerRepository {
  FailingCustomerLedgerRepository(
    super.runner, {
    this.failOnType,
    this.failOnceOnType,
  });

  final CustomerLedgerEntryType? failOnType;
  final CustomerLedgerEntryType? failOnceOnType;
  var _failedOnce = false;

  @override
  Future<CustomerLedgerEntryRow> appendEntry({
    required String customerId,
    required CustomerLedgerEntryType type,
    required int debitMinor,
    required int creditMinor,
    required String referenceType,
    required String referenceId,
    SalePaymentMethod? paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    if (failOnType == type) {
      throw SalesConflictException(
        SalesConflictCode.validation,
        'Injected ledger failure for test',
      );
    }
    if (failOnceOnType == type && !_failedOnce) {
      _failedOnce = true;
      throw SalesConflictException(
        SalesConflictCode.validation,
        'Injected ledger failure for test',
      );
    }
    return super.appendEntry(
      customerId: customerId,
      type: type,
      debitMinor: debitMinor,
      creditMinor: creditMinor,
      referenceType: referenceType,
      referenceId: referenceId,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
    );
  }
}
