import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_exceptions.dart';
import 'package:pos_mobile/features/catalog/domain/catalog_normalization.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';

class ProductFormSheet extends ConsumerStatefulWidget {
  const ProductFormSheet({
    super.key,
    this.existing,
    required this.categoryOptions,
  });

  final ProductRow? existing;
  final List<ProductCategoryRow> categoryOptions;

  @override
  ConsumerState<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _skuController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _costController;
  late final TextEditingController _sellingController;
  String? _categoryId;
  String _unit = catalogProductUnits.first;
  String? _errorMessage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final row = widget.existing;
    _nameController = TextEditingController(text: row?.name ?? '');
    _descriptionController = TextEditingController(
      text: row?.description ?? '',
    );
    _skuController = TextEditingController(text: row?.sku ?? '');
    _barcodeController = TextEditingController(text: row?.barcode ?? '');
    _costController = TextEditingController(
      text: row != null
          ? MoneyAmount.formatPkrFromMinor(row.costPriceMinor)
          : '',
    );
    _sellingController = TextEditingController(
      text: row != null
          ? MoneyAmount.formatPkrFromMinor(row.sellingPriceMinor)
          : '',
    );
    _categoryId = row?.categoryId;
    _unit = row?.unit ?? catalogProductUnits.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costController.dispose();
    _sellingController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final costMinor = MoneyAmount.parsePkrToMinor(_costController.text);
      final sellingMinor = MoneyAmount.parsePkrToMinor(_sellingController.text);
      final repo = ref.read(productRepositoryProvider);
      if (widget.existing == null) {
        await repo.createProduct(
          name: _nameController.text,
          description: _descriptionController.text,
          sku: _skuController.text,
          barcode: _barcodeController.text,
          categoryId: _categoryId,
          costPriceMinor: costMinor,
          sellingPriceMinor: sellingMinor,
          unit: _unit,
        );
      } else {
        await repo.updateProduct(
          id: widget.existing!.id,
          name: _nameController.text,
          description: _descriptionController.text,
          sku: _skuController.text,
          barcode: _barcodeController.text,
          categoryId: _categoryId,
          costPriceMinor: costMinor,
          sellingPriceMinor: sellingMinor,
          unit: _unit,
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on CatalogConflictException catch (error) {
      setState(() => _errorMessage = error.message);
    } on CatalogValidationException catch (error) {
      setState(() => _errorMessage = error.message);
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.existing != null;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEdit ? 'Edit product' : 'Add product',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Product name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU (optional)',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode (optional)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String?>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Uncategorized'),
                    ),
                    ...widget.categoryOptions.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: catalogProductUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _unit = value);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost price (PKR)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _sellingController,
                  decoration: const InputDecoration(
                    labelText: 'Selling price (PKR)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving…' : 'Save product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
