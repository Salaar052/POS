import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';

/// Inventory uses the same business-database and session gate as catalog.
class InventoryAccessGate extends ConsumerWidget {
  const InventoryAccessGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatalogAccessGate(child: child);
  }
}
