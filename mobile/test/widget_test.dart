import 'package:flutter_test/flutter_test.dart';

import 'package:pos_mobile/main.dart';

void main() {
  testWidgets('Phase 1 shell shows product title', (WidgetTester tester) async {
    await tester.pumpWidget(const PosApp());

    expect(find.textContaining('Pak POS'), findsOneWidget);
  });
}
