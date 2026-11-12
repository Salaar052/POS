/// Non-fatal business-database switch outcomes recorded at startup.
enum BootstrapLaunchIssueCode { businessDatabaseOpenFailed }

class BootstrapLaunchIssue {
  const BootstrapLaunchIssue({
    required this.code,
    required this.businessId,
    required this.userMessage,
  });

  final BootstrapLaunchIssueCode code;
  final String businessId;
  final String userMessage;
}
