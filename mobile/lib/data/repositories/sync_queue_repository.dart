import 'package:drift/drift.dart';
import 'package:pos_mobile/core/ids/uuid_generator.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/database/enums/sync_operation_status.dart';
import 'package:pos_mobile/database/enums/sync_operation_type.dart';
import 'package:pos_mobile/database/sync/sync_transition_rules.dart';
import 'package:pos_mobile/database/validators/json_validator.dart';
import 'package:pos_mobile/data/repositories/database_runner.dart';

class SyncQueueRepository {
  SyncQueueRepository(
    this._runner, {
    JsonValidator? jsonValidator,
    UuidGenerator? uuid,
    this.maxDependencyDepth = 32,
  }) : _json = jsonValidator ?? JsonValidator(),
       _uuid = uuid ?? UuidGenerator();

  final DatabaseRunner _runner;
  final JsonValidator _json;
  final UuidGenerator _uuid;
  final int maxDependencyDepth;

  Future<String> enqueueInTransaction({
    required String businessId,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operationType,
    required Map<String, Object?> payload,
    String? dependsOnOperationId,
    String? operationId,
  }) async {
    if (!SyncOperationType.isValid(operationType)) {
      throw ArgumentError('Invalid operation_type');
    }
    if (dependsOnOperationId != null && dependsOnOperationId == operationId) {
      throw SyncQueueException('Operation cannot depend on itself');
    }
    final opId = operationId ?? _uuid.v4();
    if (dependsOnOperationId != null && dependsOnOperationId == opId) {
      throw SyncQueueException('Operation cannot depend on itself');
    }
    if (dependsOnOperationId != null) {
      await _assertNoDependencyCycle(
        operationId: opId,
        dependsOnOperationId: dependsOnOperationId,
      );
    }
    final status = await _initialStatusForDependency(dependsOnOperationId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final payloadJson = _json.encodeObject(payload);
    await _runner.database
        .into(_runner.database.syncOperations)
        .insert(
          SyncOperationsCompanion.insert(
            operationId: opId,
            businessId: businessId,
            deviceId: deviceId,
            entityType: entityType,
            entityId: entityId,
            operationType: operationType,
            payloadJson: payloadJson,
            dependsOnOperationId: Value(dependsOnOperationId),
            status: status,
            createdAtMs: now,
            updatedAtMs: now,
          ),
        );
    return opId;
  }

  Future<void> transitionStatus({
    required String operationId,
    required String toStatus,
    String? errorCode,
    String? errorMessage,
  }) async {
    if (!SyncOperationStatus.isValid(toStatus)) {
      throw ArgumentError('Invalid status');
    }
    final row = await _getRequired(operationId);
    if (!SyncTransitionRules.canTransition(from: row.status, to: toStatus)) {
      throw SyncQueueException(
        'Disallowed transition ${row.status} -> $toStatus',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final retryCount = toStatus == SyncOperationStatus.failedRetryable
        ? row.retryCount + 1
        : row.retryCount;
    await (_runner.database.update(
      _runner.database.syncOperations,
    )..where((t) => t.operationId.equals(operationId))).write(
      SyncOperationsCompanion(
        status: Value(toStatus),
        updatedAtMs: Value(now),
        lastAttemptAtMs: Value(now),
        lastErrorCode: Value(errorCode),
        lastErrorMessage: Value(errorMessage),
        retryCount: Value(retryCount),
        acknowledgedAtMs: toStatus == SyncOperationStatus.acknowledged
            ? Value(now)
            : const Value.absent(),
      ),
    );

    if (toStatus == SyncOperationStatus.acknowledged) {
      await promoteDependents(operationId);
    }
  }

  Future<void> markInFlight(String operationId) {
    return transitionStatus(
      operationId: operationId,
      toStatus: SyncOperationStatus.inFlight,
    );
  }

  Future<void> acknowledge(String operationId) {
    return transitionStatus(
      operationId: operationId,
      toStatus: SyncOperationStatus.acknowledged,
    );
  }

  Future<void> markFailedRetryable({
    required String operationId,
    required String errorCode,
    required String errorMessage,
  }) {
    return transitionStatus(
      operationId: operationId,
      toStatus: SyncOperationStatus.failedRetryable,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  Future<void> retryFromFailedRetryable(String operationId) async {
    final row = await _getRequired(operationId);
    if (row.status != SyncOperationStatus.failedRetryable) {
      throw SyncQueueException('Not in failed_retryable');
    }
    await transitionStatus(
      operationId: operationId,
      toStatus: SyncOperationStatus.inFlight,
    );
  }

  Future<void> promoteDependents(String acknowledgedOperationId) async {
    final dependents =
        await (_runner.database.select(_runner.database.syncOperations)..where(
              (t) =>
                  t.dependsOnOperationId.equals(acknowledgedOperationId) &
                  t.status.equals(SyncOperationStatus.blocked),
            ))
            .get();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    for (final dep in dependents) {
      await (_runner.database.update(
        _runner.database.syncOperations,
      )..where((t) => t.operationId.equals(dep.operationId))).write(
        SyncOperationsCompanion(
          status: const Value(SyncOperationStatus.pending),
          updatedAtMs: Value(now),
        ),
      );
    }
  }

  Future<SyncOperationRow?> getOperation(String operationId) {
    return (_runner.database.select(
      _runner.database.syncOperations,
    )..where((t) => t.operationId.equals(operationId))).getSingleOrNull();
  }

  Future<List<SyncOperationRow>> listByStatus(String status) {
    return (_runner.database.select(_runner.database.syncOperations)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
        .get();
  }

  Future<String> _initialStatusForDependency(
    String? dependsOnOperationId,
  ) async {
    if (dependsOnOperationId == null) {
      return SyncOperationStatus.pending;
    }
    final parent = await getOperation(dependsOnOperationId);
    if (parent == null) {
      throw SyncQueueException('Dependency operation not found');
    }
    if (parent.status == SyncOperationStatus.acknowledged) {
      return SyncOperationStatus.pending;
    }
    return SyncOperationStatus.blocked;
  }

  Future<void> _assertNoDependencyCycle({
    required String operationId,
    required String dependsOnOperationId,
  }) async {
    String? current = dependsOnOperationId;
    for (var depth = 0; depth < maxDependencyDepth; depth++) {
      if (current == operationId) {
        throw SyncQueueException('Dependency cycle detected');
      }
      final row = await getOperation(current!);
      if (row == null) {
        return;
      }
      current = row.dependsOnOperationId;
      if (current == null) {
        return;
      }
    }
    throw SyncQueueException('Dependency chain exceeds max depth');
  }

  Future<SyncOperationRow> _getRequired(String operationId) async {
    final row = await getOperation(operationId);
    if (row == null) {
      throw SyncQueueException('Operation not found: $operationId');
    }
    return row;
  }
}

class SyncQueueException implements Exception {
  SyncQueueException(this.message);

  final String message;

  @override
  String toString() => message;
}
