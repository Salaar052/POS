import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/services/database_service.dart';

typedef TestContainerHandle = ({
  ProviderContainer container,
  DatabaseService service,
});

TestContainerHandle createInMemoryAppContainer() {
  final service = DatabaseService.inMemory();
  final container = ProviderContainer(
    overrides: [
      databaseServiceProvider.overrideWithValue(service),
    ],
  );
  return (container: container, service: service);
}
