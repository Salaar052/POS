import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Inventory',
      description: 'Stock levels, adjustments, and perpetual inventory.',
      comingInPhase: 'Planned for a later phase — stock tracking.',
    );
  }
}
