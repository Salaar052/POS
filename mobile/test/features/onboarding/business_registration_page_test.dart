import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/launch/app_launch_resolver.dart';
import 'package:pos_mobile/app/providers/app_launch_provider.dart';
import 'package:pos_mobile/app/providers/onboarding_providers.dart';
import 'package:pos_mobile/app/router/app_routes.dart';
import 'package:pos_mobile/core/network/business_registration_api.dart';
import 'package:pos_mobile/core/network/business_registration_models.dart';

import 'dart:async';

import 'package:pos_mobile/features/onboarding/data/onboarding_recovery_store.dart';
import 'package:pos_mobile/features/onboarding/presentation/business_registration_page.dart';

import '../../fakes/fake_secure_storage_service.dart';

void main() {
  testWidgets('shows validation errors and prevents duplicate submit', (
    tester,
  ) async {
    final secureStorage = FakeSecureStorageService();
    final api = _SlowStubApi();
    tester.view.physicalSize = const Size(1280, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          businessRegistrationApiProvider.overrideWithValue(api),
          onboardingRecoveryStoreProvider.overrideWithValue(
            OnboardingRecoveryStore(secureStorage),
          ),
          appLaunchResolutionProvider.overrideWith(
            (ref) async => const AppLaunchResolution(
              destination: AppLaunchDestination.onboardingWelcome,
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: AppRoutes.onboardingRegister,
                builder: (_, _) => const BusinessRegistrationPage(),
              ),
              GoRoute(
                path: AppRoutes.onboardingComplete,
                builder: (_, _) => const Scaffold(body: Text('complete')),
              ),
            ],
            initialLocation: AppRoutes.onboardingRegister,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create business account'));
    await tester.pump();

    expect(find.textContaining('at least'), findsWidgets);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Karachi Shop');
    await tester.enterText(fields.at(1), 'Ali Khan');
    await tester.enterText(fields.at(2), 'ali@example.com');
    await tester.enterText(fields.at(3), 'secure-pass-12');

    final submit = find.text('Create business account');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    expect(api.submitCount, 1);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.text('secure-pass-12'), findsOneWidget);

    api.releaseRequest.complete();
    await tester.pumpAndSettle();
  });
}

class _SlowStubApi implements BusinessRegistrationApi {
  final releaseRequest = Completer<void>();
  int submitCount = 0;

  @override
  Future<RegisterBusinessResult> register(
    RegisterBusinessRequest request,
  ) async {
    submitCount++;
    await releaseRequest.future;
    throw const RegistrationApiException(
      RegistrationApiFailureKind.network,
      'offline',
    );
  }
}
