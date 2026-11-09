import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Expenses',
      description: 'Operating expenses and categories.',
      comingInPhase: 'Planned for a later phase — expense tracking.',
    );
  }
}
