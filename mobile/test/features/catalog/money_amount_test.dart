import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';

void main() {
  test('parses and formats PKR without floating point storage', () {
    expect(MoneyAmount.parsePkrToMinor('12.5'), 1250);
    expect(MoneyAmount.formatPkrFromMinor(1250), '12.50');
  });

  test('rejects invalid decimal input', () {
    expect(
      () => MoneyAmount.parsePkrToMinor('12.345'),
      throwsA(isA<CatalogValidationException>()),
    );
  });
}
