import 'package:drift/drift.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/receipts/domain/receipt_enums.dart';
import 'package:uuid/uuid.dart';

class PrintAttemptRepository {
  PrintAttemptRepository(this._runner);

  final DatabaseRunner _runner;
  static const _uuid = Uuid();

  Future<PrintAttemptRow> logAttempt({
    required String referenceType,
    required String referenceId,
    required String documentNumber,
    required ReceiptPrintType printType,
    required ReceiptPrintResult result,
    required int paperWidthMm,
    String? printerId,
    String? errorDetail,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _runner.database
        .into(_runner.database.printAttempts)
        .insert(
          PrintAttemptsCompanion.insert(
            id: id,
            referenceType: referenceType,
            referenceId: referenceId,
            documentNumber: documentNumber,
            printerId: Value(printerId),
            paperWidthMm: paperWidthMm,
            printType: printType.storage,
            result: result.storage,
            errorDetail: Value(errorDetail),
            createdAtMs: now,
          ),
        );
    return (_runner.database.select(
      _runner.database.printAttempts,
    )..where((t) => t.id.equals(id))).getSingle();
  }
}
