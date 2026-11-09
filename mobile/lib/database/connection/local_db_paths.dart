/// Pre-provision database file (no business row). Phase 4 may migrate to
/// [businessDatabaseFileName] after activation.
const String localBootstrapDatabaseFileName = 'local.sqlite';

String businessDatabaseFileName(String businessId) =>
    'business_$businessId.sqlite';
