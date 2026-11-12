import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/inventory_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/features/inventory/domain/inventory_exceptions.dart';
import 'package:pos_mobile/features/inventory/domain/product_quantity.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/features/inventory/presentation/inventory_access_gate.dart';
import 'package:pos_mobile/features/inventory/presentation/stock_detail_sheet.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final _searchController = TextEditingController();
  StockStatus? _statusFilter;
  List<InventoryOverviewRow> _rows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final rows = await repo.listOverview(
        nameQuery: _searchController.text,
        statusFilter: _statusFilter,
        limit: 200,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color? _statusColor(StockStatus status, ColorScheme scheme) {
    return switch (status) {
      StockStatus.outOfStock => scheme.error,
      StockStatus.lowStock => Colors.orange,
      StockStatus.inStock => scheme.primary,
      StockStatus.notConfigured => null,
    };
  }

  String _statusLabel(StockStatus status) {
    return switch (status) {
      StockStatus.outOfStock => 'Out of stock',
      StockStatus.lowStock => 'Low stock',
      StockStatus.inStock => 'In stock',
      StockStatus.notConfigured => 'No minimum set',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InventoryAccessGate(
      child: SizedBox.expand(
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Inventory', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search products',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _reload,
                    ),
                  ),
                  onSubmitted: (_) => _reload(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    FilterChip(
                      label: const Text('Low stock'),
                      selected: _statusFilter == StockStatus.lowStock,
                      onSelected: (_) {
                        setState(() {
                          _statusFilter = _statusFilter == StockStatus.lowStock
                              ? null
                              : StockStatus.lowStock;
                        });
                        _reload();
                      },
                    ),
                    FilterChip(
                      label: const Text('Out of stock'),
                      selected: _statusFilter == StockStatus.outOfStock,
                      onSelected: (_) {
                        setState(() {
                          _statusFilter =
                              _statusFilter == StockStatus.outOfStock
                              ? null
                              : StockStatus.outOfStock;
                        });
                        _reload();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${_rows.length} product(s)',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_rows.isEmpty) {
      return const Center(child: Text('No products match this filter.'));
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      itemCount: _rows.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final row = _rows[index];
        final qty = ProductQuantity.formatFromBase(
          row.quantityOnHandBase,
          row.product.unit,
        );
        return ListTile(
          title: Text(row.product.name),
          subtitle: Text(
            [
              if (row.product.sku != null) 'SKU ${row.product.sku}',
              'On hand: $qty ${row.product.unit}',
              _statusLabel(row.status),
            ].join(' · '),
          ),
          textColor: _statusColor(row.status, scheme),
          onTap: () => _openDetail(row),
        );
      },
    );
  }

  Future<void> _openDetail(InventoryOverviewRow row) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StockDetailSheet(overview: row),
    );
    if (changed == true) {
      await _reload();
    }
  }
}
