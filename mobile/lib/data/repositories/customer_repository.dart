import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/customer_ledger_repository.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
import 'package:uuid/uuid.dart';

class CustomerRepository {
  CustomerRepository(this._runner, {CustomerLedgerRepository? ledger})
    : _ledger = ledger ?? CustomerLedgerRepository(_runner);

  final DatabaseRunner _runner;
  final CustomerLedgerRepository _ledger;
  static const _uuid = Uuid();
  static const refTypeCustomerPayment = 'CUSTOMER_PAYMENT';

  Future<CustomerRow> createCustomer({
    required String name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    final displayName = CatalogNormalization.requireCategoryName(name);
    final normalized = CatalogNormalization.normalizeCategoryName(displayName);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _runner.database
        .into(_runner.database.customers)
        .insert(
          CustomersCompanion.insert(
            id: id,
            name: displayName,
            normalizedName: normalized,
            phone: Value(_trimOrNull(phone)),
            phoneNormalized: Value(_normalizePhone(phone)),
            address: Value(_trimOrNull(address)),
            notes: Value(_trimOrNull(notes)),
            createdAtMs: now,
            updatedAtMs: now,
          ),
        );
    return (await getById(id))!;
  }

  Future<CustomerRow> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    final existing = await getById(id);
    if (existing == null) {
      throw SalesConflictException(
        SalesConflictCode.notFound,
        'Customer not found',
      );
    }
    final displayName = CatalogNormalization.requireCategoryName(name);
    final normalized = CatalogNormalization.normalizeCategoryName(displayName);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.customers,
    )..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        name: Value(displayName),
        normalizedName: Value(normalized),
        phone: Value(_trimOrNull(phone)),
        phoneNormalized: Value(_normalizePhone(phone)),
        address: Value(_trimOrNull(address)),
        notes: Value(_trimOrNull(notes)),
        updatedAtMs: Value(now),
      ),
    );
    return (await getById(id))!;
  }

  Future<void> archiveCustomer(String id) async {
    final existing = await getById(id);
    if (existing == null) {
      throw SalesConflictException(
        SalesConflictCode.notFound,
        'Customer not found',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_runner.database.update(
      _runner.database.customers,
    )..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        isActive: const Value(false),
        archivedAtMs: Value(now),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<CustomerRow?> getById(String id) {
    return (_runner.database.select(
      _runner.database.customers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<CustomerRow>> listCustomers({
    String? query,
    bool includeArchived = false,
    int limit = 100,
    int offset = 0,
  }) async {
    final select = _runner.database.select(_runner.database.customers)
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
      ..limit(limit, offset: offset);
    if (!includeArchived) {
      select.where((t) => t.isActive.equals(true) & t.archivedAtMs.isNull());
    }
    if (query != null && query.trim().isNotEmpty) {
      final pattern = '%${query.trim().toLowerCase()}%';
      select.where(
        (t) => t.normalizedName.like(pattern) | t.phoneNormalized.like(pattern),
      );
    }
    return select.get();
  }

  Future<int> outstandingBalanceMinor(String customerId) =>
      _ledger.outstandingBalanceMinor(customerId);

  Future<List<CustomerLedgerEntryRow>> listLedger(
    String customerId, {
    int limit = 100,
  }) => _ledger.listForCustomer(customerId, limit: limit);

  Future<CustomerLedgerEntryRow> recordCustomerPayment({
    required String customerId,
    required int amountMinor,
    required SalePaymentMethod method,
    required String idempotencyKey,
    String? referenceNumber,
    String? notes,
  }) async {
    MoneyAmount.assertNonNegativeMinor(amountMinor);
    if (amountMinor <= 0) {
      throw SalesConflictException(
        SalesConflictCode.validation,
        'Payment amount must be positive',
      );
    }
    return _runner.runInTransaction(() async {
      final customer = await getById(customerId);
      if (customer == null) {
        throw SalesConflictException(
          SalesConflictCode.notFound,
          'Customer not found',
        );
      }
      final dup = await _ledger.findByReference(
        type: CustomerLedgerEntryType.customerPayment,
        referenceType: refTypeCustomerPayment,
        referenceId: idempotencyKey,
      );
      if (dup != null) {
        _assertCustomerPaymentIdempotency(
          existing: dup,
          amountMinor: amountMinor,
          method: method,
          referenceNumber: referenceNumber,
          notes: notes,
        );
        return dup;
      }
      final outstanding = await _ledger.outstandingBalanceMinor(customerId);
      if (amountMinor > outstanding) {
        throw SalesConflictException(
          SalesConflictCode.paymentExceedsDue,
          'Payment exceeds outstanding receivable',
        );
      }
      return _ledger.appendEntry(
        customerId: customerId,
        type: CustomerLedgerEntryType.customerPayment,
        debitMinor: 0,
        creditMinor: amountMinor,
        referenceType: refTypeCustomerPayment,
        referenceId: idempotencyKey,
        paymentMethod: method,
        referenceNumber: referenceNumber,
        notes: notes,
      );
    });
  }

  void _assertCustomerPaymentIdempotency({
    required CustomerLedgerEntryRow existing,
    required int amountMinor,
    required SalePaymentMethod method,
    String? referenceNumber,
    String? notes,
  }) {
    if (existing.creditMinor != amountMinor) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with a different amount',
      );
    }
    if (existing.paymentMethod != method.storage) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with a different method',
      );
    }
    if ((existing.referenceNumber ?? '') != (referenceNumber ?? '')) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with a different reference',
      );
    }
    if ((existing.notes ?? '') != (notes ?? '')) {
      throw SalesConflictException(
        SalesConflictCode.idempotencyConflict,
        'Payment idempotency key reused with different notes',
      );
    }
  }

  String? _trimOrNull(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizePhone(String? raw) {
    if (raw == null) {
      return null;
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : digits;
  }
}
