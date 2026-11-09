import 'package:flutter_test/flutter_test.dart';

import 'package:pos_mobile/main.dart';

void main() {
  testWidgets('PosApp shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const PosApp());

    expect(find.textContaining('Pak POS'), findsOneWidget);
  });
}
