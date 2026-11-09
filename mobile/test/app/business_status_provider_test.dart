import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/business_status_provider.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/services/database_service.dart';

void main() {
  test('businessProvisionStatusProvider reports unprovisioned bootstrap db', () async {
    final service = await DatabaseService.open(
      storageDirectoryOverride:
          '${Directory.systemTemp.path}/pakpos_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    addTearDown(() => service.dispose());

    final container = ProviderContainer(
      overrides: [databaseServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final status = await container.read(businessProvisionStatusProvider.future);
    expect(status.isProvisioned, isFalse);
    expect(status.businessName, isNull);
  });
}
