import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Point of Sale',
      description: 'Checkout, payments, and receipts for in-store sales.',
      comingInPhase:
          'Planned for a later phase — checkout and PKR tender types.',
    );
  }
}
