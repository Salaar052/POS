import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/inventory_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/features/inventory/domain/product_quantity.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';
import 'package:pos_mobile/features/inventory/presentation/stock_adjustment_sheet.dart';
import 'package:pos_mobile/database/app_database.dart';

class StockDetailSheet extends ConsumerStatefulWidget {
  const StockDetailSheet({super.key, required this.overview});

  final InventoryOverviewRow overview;

  @override
  ConsumerState<StockDetailSheet> createState() => _StockDetailSheetState();
}

class _StockDetailSheetState extends ConsumerState<StockDetailSheet> {
  List<StockMovementRow> _movements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final movements = await ref
        .read(inventoryRepositoryProvider)
        .listMovements(widget.overview.product.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _movements = movements;
      _loading = false;
    });
  }

  Future<void> _adjust(StockMovementType type, String title) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StockAdjustmentSheet(
        product: widget.overview.product,
        movementType: type,
        title: title,
        requireConfirmation: !type.isInbound,
      ),
    );
    if (saved == true) {
      await _load();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _openingStock() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StockAdjustmentSheet(
        product: widget.overview.product,
        movementType: StockMovementType.openingStock,
        title: 'Opening stock',
      ),
    );
    if (saved == true) {
      await _load();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _setMinimum() async {
    final controller = TextEditingController(
      text: widget.overview.minimumStockBase != null
          ? ProductQuantity.formatFromBase(
              widget.overview.minimumStockBase!,
              widget.overview.product.unit,
            )
          : '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minimum stock threshold'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Minimum (leave blank to clear)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) {
      return;
    }
    final trimmed = result.trim();
    int? minBase;
    if (trimmed.isNotEmpty) {
      minBase = ProductQuantity.parseToBase(
        trimmed,
        widget.overview.product.unit,
      );
    }
    await ref
        .read(inventoryRepositoryProvider)
        .setMinimumStock(
          productId: widget.overview.product.id,
          minimumStockBase: minBase,
        );
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.overview.product;
    final onHand = ProductQuantity.formatFromBase(
      widget.overview.quantityOnHandBase,
      product.unit,
    );
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(product.name, style: theme.textTheme.titleLarge),
          Text('On hand: $onHand ${product.unit}'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              OutlinedButton(
                onPressed: _openingStock,
                child: const Text('Opening stock'),
              ),
              OutlinedButton(
                onPressed: () =>
                    _adjust(StockMovementType.adjustmentIn, 'Stock increase'),
                child: const Text('Increase'),
              ),
              OutlinedButton(
                onPressed: () =>
                    _adjust(StockMovementType.adjustmentOut, 'Stock decrease'),
                child: const Text('Decrease'),
              ),
              OutlinedButton(
                onPressed: () =>
                    _adjust(StockMovementType.damage, 'Damage / loss'),
                child: const Text('Damage'),
              ),
              OutlinedButton(
                onPressed: () =>
                    _adjust(StockMovementType.expired, 'Expired stock'),
                child: const Text('Expired'),
              ),
              OutlinedButton(
                onPressed: _setMinimum,
                child: const Text('Min threshold'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Movement history', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_movements.isEmpty)
            const Text('No movements yet.')
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _movements.length,
                itemBuilder: (context, index) {
                  final m = _movements[index];
                  final qty = ProductQuantity.formatFromBase(
                    m.quantityBase,
                    product.unit,
                  );
                  return ListTile(
                    dense: true,
                    title: Text(m.movementType),
                    subtitle: Text(
                      'Qty $qty · after ${ProductQuantity.formatFromBase(m.resultingQuantityBase, product.unit)}'
                      '${m.reason != null ? ' · ${m.reason}' : ''}',
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
