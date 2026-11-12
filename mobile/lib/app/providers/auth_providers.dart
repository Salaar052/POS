import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pos_mobile/app/providers/secure_storage_provider.dart';
import 'package:pos_mobile/core/network/auth_api.dart';
import 'package:pos_mobile/features/auth/application/auth_session_controller.dart';
import 'package:pos_mobile/features/auth/application/auth_session_launch_service.dart';
import 'package:pos_mobile/features/auth/data/auth_session_store.dart';

final authApiProvider = Provider<AuthApi>((ref) => HttpAuthApi());

final authSessionStoreProvider = Provider<AuthSessionStore>((ref) {
  return AuthSessionStore(ref.watch(secureStorageServiceProvider));
});

final authSessionControllerProvider =
    ChangeNotifierProvider<AuthSessionController>((ref) {
      return AuthSessionController(
        store: ref.watch(authSessionStoreProvider),
        api: ref.watch(authApiProvider),
      );
    });

final authSessionLaunchServiceProvider = Provider<AuthSessionLaunchService>((
  ref,
) {
  return AuthSessionLaunchService(
    store: ref.watch(authSessionStoreProvider),
    api: ref.watch(authApiProvider),
    sessionController: ref.watch(authSessionControllerProvider),
  );
});
