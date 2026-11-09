import 'package:flutter/material.dart';
import 'package:pos_mobile/shared/widgets/placeholder_feature_body.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureBody(
      title: 'Products',
      description: 'Product catalog, barcodes, and pricing.',
      comingInPhase: 'Planned for a later phase — catalog management.',
    );
  }
}
