import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class PurchasesPage extends StatelessWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Purchases',
      description: 'Purchase orders and goods received.',
      comingInPhase: 'Planned for a later phase — purchasing.',
    );
  }
}
