import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/app/app.dart';
import 'package:pos_mobile/app/launch/app_launch_resolver.dart';
import 'package:pos_mobile/app/providers/app_launch_provider.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/app/router/app_router.dart';
import 'package:pos_mobile/app/router/app_routes.dart';

import '../helpers/test_app_container.dart';

void main() {
  testWidgets('blocks /pos while owner pending', (tester) async {
    final handle = createInMemoryAppContainer();
    final container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(handle.service),
        appLaunchResolutionProvider.overrideWith(
          (ref) async => const AppLaunchResolution(
            destination: AppLaunchDestination.ownerPendingVerification,
          ),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      handle.service.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PakPosApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    container.read(routerProvider).go(AppRoutes.pos);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Business account created'), findsOneWidget);
  });

  testWidgets('blocks /pos for legacy READY', (tester) async {
    final handle = createInMemoryAppContainer();
    final container = ProviderContainer(
      overrides: [
        databaseServiceProvider.overrideWithValue(handle.service),
        appLaunchResolutionProvider.overrideWith(
          (ref) async => const AppLaunchResolution(
            destination: AppLaunchDestination.loginRequired,
            sessionBusinessId: '550e8400-e29b-41d4-a716-446655440000',
          ),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      handle.service.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const PakPosApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    container.read(routerProvider).go(AppRoutes.pos);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Owner sign-in'), findsOneWidget);
  });
}
