import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/inventory_providers.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/inventory/domain/inventory_exceptions.dart';
import 'package:pos_mobile/features/inventory/domain/product_quantity.dart';
import 'package:pos_mobile/features/inventory/domain/stock_movement_type.dart';
import 'package:uuid/uuid.dart';

class StockAdjustmentSheet extends ConsumerStatefulWidget {
  const StockAdjustmentSheet({
    super.key,
    required this.product,
    required this.movementType,
    required this.title,
    this.requireConfirmation = false,
  });

  final ProductRow product;
  final StockMovementType movementType;
  final String title;
  final bool requireConfirmation;

  @override
  ConsumerState<StockAdjustmentSheet> createState() =>
      _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends ConsumerState<StockAdjustmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Reason is required');
      return;
    }
    if (widget.requireConfirmation) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm stock decrease'),
          content: Text(
            'Record ${widget.title.toLowerCase()} for "${widget.product.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (ok != true) {
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final qtyBase = ProductQuantity.parseToBase(
        _quantityController.text,
        widget.product.unit,
      );
      final repo = ref.read(inventoryRepositoryProvider);
      final key = const Uuid().v4();
      await repo.applyMovement(
        ApplyStockMovementRequest(
          productId: widget.product.id,
          type: widget.movementType,
          quantityBase: qtyBase,
          idempotencyKey: key,
          reason: reason,
        ),
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on InventoryConflictException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: theme.textTheme.titleLarge),
            Text(
              '${widget.product.name} · unit: ${widget.product.unit}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (_error != null)
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: ProductQuantity.allowsFractions(widget.product.unit)
                    ? 'Quantity (decimals allowed)'
                    : 'Quantity (whole units)',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving…' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
