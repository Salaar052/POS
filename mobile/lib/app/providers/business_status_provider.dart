import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';

/// Read-only view of whether a business row exists in local SQLite.
class BusinessProvisionStatus {
  const BusinessProvisionStatus({
    required this.isProvisioned,
    this.businessName,
    this.currencyCode,
  });

  final bool isProvisioned;
  final String? businessName;
  final String? currencyCode;
}

/// Loads provisioning state from [LocalBusinessRepository]; does not provision.
final businessProvisionStatusProvider = FutureProvider<BusinessProvisionStatus>(
  (ref) async {
    final repo = ref.watch(localBusinessRepositoryProvider);
    final row = await repo.getBusiness();
    if (row == null) {
      return const BusinessProvisionStatus(isProvisioned: false);
    }
    return BusinessProvisionStatus(
      isProvisioned: true,
      businessName: row.name,
      currencyCode: row.currencyCode,
    );
  },
);
