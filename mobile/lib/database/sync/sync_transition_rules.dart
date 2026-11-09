import 'package:pos_mobile/database/enums/sync_operation_status.dart';

/// Allowed sync queue status transitions (repository-enforced).
class SyncTransitionRules {
  static bool canTransition({required String from, required String to}) {
    if (from == to) {
      return true;
    }
    if (SyncOperationStatus.terminal.contains(from)) {
      return false;
    }
    return _allowed[from]?.contains(to) ?? false;
  }

  static const Map<String, Set<String>> _allowed = {
    SyncOperationStatus.blocked: {
      SyncOperationStatus.pending,
      SyncOperationStatus.failedTerminal,
      SyncOperationStatus.reconciliationRequired,
    },
    SyncOperationStatus.pending: {
      SyncOperationStatus.inFlight,
      SyncOperationStatus.failedTerminal,
      SyncOperationStatus.reconciliationRequired,
    },
    SyncOperationStatus.inFlight: {
      SyncOperationStatus.acknowledged,
      SyncOperationStatus.failedRetryable,
      SyncOperationStatus.failedTerminal,
      SyncOperationStatus.reconciliationRequired,
    },
    SyncOperationStatus.failedRetryable: {
      SyncOperationStatus.inFlight,
      SyncOperationStatus.failedTerminal,
      SyncOperationStatus.reconciliationRequired,
    },
  };
}
