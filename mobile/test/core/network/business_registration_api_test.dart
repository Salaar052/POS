import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos_mobile/core/network/business_registration_api.dart';
import 'package:pos_mobile/core/network/business_registration_models.dart';

void main() {
  const successBody = {
    'business': {
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'name': 'Test Shop',
      'phone': null,
      'email': null,
      'currencyCode': 'PKR',
      'timezone': 'Asia/Karachi',
      'status': 'ACTIVE',
      'createdAt': '2026-11-10T10:00:00.000Z',
    },
    'owner': {
      'id': '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      'name': 'Owner',
      'email': 'owner@example.com',
      'status': 'PENDING_VERIFICATION',
      'createdAt': '2026-11-10T10:00:00.000Z',
    },
    'membership': {
      'id': '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
      'role': 'OWNER',
      'status': 'ACTIVE',
    },
  };

  final request = RegisterBusinessRequest(
    businessName: 'Test Shop',
    ownerName: 'Owner',
    ownerEmail: 'owner@example.com',
    password: 'valid-pass-12',
  );

  test('serializes registration request JSON', () {
    final json = request.toJson();
    expect(json['businessName'], 'Test Shop');
    expect(json['password'], 'valid-pass-12');
    expect(json.containsKey('businessPhone'), isFalse);
  });

  test('parses 201 success', () async {
    final client = MockClient((_) async {
      return http.Response(jsonEncode(successBody), 201);
    });
    final api = HttpBusinessRegistrationApi(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:3000/businesses/register'),
    );
    final result = await api.register(request);
    final business = successBody['business']! as Map<String, dynamic>;
    expect(result.business.id, business['id']);
    expect(result.membership.role, 'OWNER');
  });

  test('maps 400 validation response', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'message': [
            'password must include at least one letter and one number',
          ],
        }),
        400,
      );
    });
    final api = HttpBusinessRegistrationApi(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:3000/businesses/register'),
    );
    expect(
      () => api.register(request),
      throwsA(
        predicate<RegistrationApiException>(
          (e) => e.kind == RegistrationApiFailureKind.validation,
        ),
      ),
    );
  });

  test('maps 409 duplicate email', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({'message': 'Email already registered'}),
        409,
      );
    });
    final api = HttpBusinessRegistrationApi(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:3000/businesses/register'),
    );
    expect(
      () => api.register(request),
      throwsA(
        predicate<RegistrationApiException>(
          (e) => e.kind == RegistrationApiFailureKind.duplicateEmail,
        ),
      ),
    );
  });

  test('maps network failure', () async {
    final client = MockClient((_) async {
      throw http.ClientException('offline');
    });
    final api = HttpBusinessRegistrationApi(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:3000/businesses/register'),
    );
    expect(
      () => api.register(request),
      throwsA(
        predicate<RegistrationApiException>(
          (e) => e.kind == RegistrationApiFailureKind.network,
        ),
      ),
    );
  });

  test('maps timeout', () async {
    final client = MockClient((_) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      return http.Response('{}', 201);
    });
    final api = HttpBusinessRegistrationApi(
      client: client,
      timeout: const Duration(milliseconds: 50),
      endpoint: Uri.parse('http://127.0.0.1:3000/businesses/register'),
    );
    expect(
      () => api.register(request),
      throwsA(
        predicate<RegistrationApiException>(
          (e) => e.kind == RegistrationApiFailureKind.timeout,
        ),
      ),
    );
  });

  test('maps malformed success JSON', () async {
    final client = MockClient((_) async {
      return http.Response('not-json', 201);
    });
    final api = HttpBusinessRegistrationApi(
      client: client,
      endpoint: Uri.parse('http://127.0.0.1:3000/businesses/register'),
    );
    expect(
      () => api.register(request),
      throwsA(
        predicate<RegistrationApiException>(
          (e) => e.kind == RegistrationApiFailureKind.malformedResponse,
        ),
      ),
    );
  });
}
