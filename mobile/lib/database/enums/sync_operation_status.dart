abstract final class SyncOperationStatus {
  static const pending = 'pending';
  static const blocked = 'blocked';
  static const inFlight = 'in_flight';
  static const acknowledged = 'acknowledged';
  static const failedRetryable = 'failed_retryable';
  static const failedTerminal = 'failed_terminal';
  static const reconciliationRequired = 'reconciliation_required';

  static const terminal = [
    acknowledged,
    failedTerminal,
    reconciliationRequired,
  ];

  static const all = [
    pending,
    blocked,
    inFlight,
    acknowledged,
    failedRetryable,
    failedTerminal,
    reconciliationRequired,
  ];

  static bool isValid(String value) => all.contains(value);
}
