import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class SuppliersPage extends StatelessWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Suppliers',
      description: 'Supplier contacts and purchase links.',
      comingInPhase: 'Planned for a later phase — supplier management.',
    );
  }
}
