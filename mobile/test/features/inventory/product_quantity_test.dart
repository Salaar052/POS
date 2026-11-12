import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';
import 'package:pos_mobile/features/inventory/domain/product_quantity.dart';

void main() {
  test('parses integer units', () {
    expect(ProductQuantity.parseToBase('12', 'each'), 12);
    expect(ProductQuantity.formatFromBase(12, 'each'), '12');
  });

  test('parses decimal kg to milli base', () {
    expect(ProductQuantity.parseToBase('1.5', 'kg'), 1500);
    expect(ProductQuantity.formatFromBase(1500, 'kg'), '1.500');
  });

  test('rejects invalid decimal on integer unit', () {
    expect(
      () => ProductQuantity.parseToBase('1.5', 'each'),
      throwsA(isA<CatalogValidationException>()),
    );
  });
}
