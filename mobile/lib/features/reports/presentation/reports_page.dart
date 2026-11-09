import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Reports',
      description: 'Sales, inventory, and financial summaries.',
      comingInPhase: 'Planned for a later phase — reporting.',
    );
  }
}
