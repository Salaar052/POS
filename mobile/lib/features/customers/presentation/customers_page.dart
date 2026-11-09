import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Customers',
      description: 'Customer profiles and purchase history.',
      comingInPhase: 'Planned for a later phase — customer management.',
    );
  }
}
