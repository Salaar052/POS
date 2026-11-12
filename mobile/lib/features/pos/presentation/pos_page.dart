import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/app/providers/sales_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/data/repositories/inventory_repository.dart';
import 'package:pos_mobile/data/repositories/sales_repository.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
import 'package:pos_mobile/app/providers/catalog_providers.dart';
import 'package:uuid/uuid.dart';

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CatalogAccessGate(child: _PosBody());
  }
}

class _PosBody extends ConsumerStatefulWidget {
  const _PosBody();

  @override
  ConsumerState<_PosBody> createState() => _PosBodyState();
}

class _PosBodyState extends ConsumerState<_PosBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  SaleRow? _activeDraft;
  List<SaleItemRow> _cartItems = [];
  List<CustomerRow> _customers = [];
  bool _loading = true;
  String? _error;
  String? _selectedCustomerId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _bootstrapCart();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sales = ref.read(salesRepositoryProvider);
      final draft = await sales.createDraft();
      final items = await sales.listSaleItems(draft.id);
      final customers = await ref
          .read(customerRepositoryProvider)
          .listCustomers(limit: 200);
      if (!mounted) {
        return;
      }
      setState(() {
        _activeDraft = draft;
        _cartItems = items;
        _customers = customers;
        _loading = false;
      });
    } on SalesConflictException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _reloadCart() async {
    final draft = _activeDraft;
    if (draft == null) {
      return;
    }
    final sales = ref.read(salesRepositoryProvider);
    final sale = await sales.getSaleById(draft.id);
    final items = await sales.listSaleItems(draft.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _activeDraft = sale;
      _cartItems = items;
      _selectedCustomerId = sale?.customerId;
    });
  }

  Future<void> _searchAndAddProduct() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _activeDraft == null) {
      return;
    }
    final products = ref.read(productRepositoryProvider);
    var product = await products.findByBarcode(query);
    product ??= await products.findBySku(query);
    final nameHits = await products.searchByName(query, limit: 1);
    if (product == null && nameHits.isNotEmpty) {
      product = nameHits.first;
    }
    if (product == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No active product found')));
      return;
    }
    final inventory = InventoryRepository(ref.read(databaseRunnerProvider));
    final onHand = await inventory.getOnHandBase(product.id);
    if (onHand <= 0) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} is out of stock')),
      );
      return;
    }
    try {
      await ref
          .read(salesRepositoryProvider)
          .addDraftItem(
            saleId: _activeDraft!.id,
            productId: product.id,
            quantityBase: 1,
          );
      _searchController.clear();
      await _reloadCart();
    } on SalesConflictException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _checkout() async {
    final draft = _activeDraft;
    if (draft == null || _cartItems.isEmpty) {
      return;
    }
    final total = draft.totalMinor;
    final isWalkIn = _selectedCustomerId == null;
    final payAmount = isWalkIn ? total : total;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm checkout'),
        content: Text(
          'Total: ${MoneyAmount.formatPkrFromMinor(total)} PKR\n'
          '${isWalkIn ? 'Walk-in — full cash payment.' : 'Customer account — payment recorded now.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Complete sale'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    final checkoutKey = const Uuid().v4();
    final paymentKey = const Uuid().v4();
    try {
      await ref
          .read(salesRepositoryProvider)
          .checkout(
            saleId: draft.id,
            checkoutIdempotencyKey: checkoutKey,
            payments: [
              CheckoutPaymentInput(
                method: SalePaymentMethod.cash,
                amountMinor: payAmount,
                idempotencyKey: paymentKey,
              ),
            ],
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sale completed')));
      await _bootstrapCart();
    } on SalesConflictException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    final draft = _activeDraft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Cart'),
            Tab(text: 'Drafts'),
            Tab(text: 'History'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _buildCartTab(draft),
              _DraftsTab(
                onResume: (sale) async {
                  setState(() => _activeDraft = sale);
                  await _reloadCart();
                  _tabs.animateTo(0);
                },
              ),
              const _SalesHistoryTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartTab(SaleRow? draft) {
    if (draft == null) {
      return const Center(child: Text('No active cart'));
    }
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search product (name, SKU, barcode)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _searchAndAddProduct,
                ),
              ),
              onSubmitted: (_) => _searchAndAddProduct(),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String?>(
              initialValue: _selectedCustomerId,
              decoration: const InputDecoration(labelText: 'Customer'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Walk-in customer'),
                ),
                ..._customers.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: (value) async {
                await ref
                    .read(salesRepositoryProvider)
                    .setDraftCustomer(saleId: draft.id, customerId: value);
                setState(() => _selectedCustomerId = value);
                await _reloadCart();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._cartItems.map(
              (item) => _CartLineTile(
                item: item,
                onChanged: _reloadCart,
                saleId: draft.id,
              ),
            ),
            if (_cartItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text('Cart is empty — search and add products.'),
              ),
            const Divider(),
            Text(
              'Subtotal: ${MoneyAmount.formatPkrFromMinor(draft.subtotalMinor)} PKR',
            ),
            Text(
              'Discount: ${MoneyAmount.formatPkrFromMinor(draft.discountMinor)} PKR',
            ),
            Text(
              'Total: ${MoneyAmount.formatPkrFromMinor(draft.totalMinor)} PKR',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _cartItems.isEmpty ? null : _checkout,
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({
    required this.item,
    required this.saleId,
    required this.onChanged,
  });

  final SaleItemRow item;
  final String saleId;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = InventoryRepository(ref.read(databaseRunnerProvider));
    return FutureBuilder<int>(
      future: inventory.getOnHandBase(item.productId),
      builder: (context, snapshot) {
        final stock = snapshot.data;
        return Card(
          child: ListTile(
            title: Text(item.productNameSnapshot),
            subtitle: Text(
              'Qty ${item.quantityBase} · Stock ${stock ?? '…'} · '
              '${MoneyAmount.formatPkrFromMinor(item.lineTotalMinor)} PKR',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () async {
                    if (item.quantityBase <= 1) {
                      await ref
                          .read(salesRepositoryProvider)
                          .removeDraftItem(saleId: saleId, itemId: item.id);
                    } else {
                      await ref
                          .read(salesRepositoryProvider)
                          .updateDraftItem(
                            saleId: saleId,
                            itemId: item.id,
                            quantityBase: item.quantityBase - 1,
                          );
                    }
                    await onChanged();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await ref
                        .read(salesRepositoryProvider)
                        .updateDraftItem(
                          saleId: saleId,
                          itemId: item.id,
                          quantityBase: item.quantityBase + 1,
                        );
                    await onChanged();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DraftsTab extends ConsumerStatefulWidget {
  const _DraftsTab({required this.onResume});

  final Future<void> Function(SaleRow sale) onResume;

  @override
  ConsumerState<_DraftsTab> createState() => _DraftsTabState();
}

class _DraftsTabState extends ConsumerState<_DraftsTab> {
  List<SaleRow> _drafts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final rows = await ref
        .read(salesRepositoryProvider)
        .listSales(status: SaleStatus.draft, limit: 100);
    if (!mounted) {
      return;
    }
    setState(() {
      _drafts = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_drafts.isEmpty) {
      return const Center(child: Text('No saved drafts'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _drafts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final draft = _drafts[index];
        return ListTile(
          title: Text(draft.saleNumber),
          subtitle: Text(
            '${draft.customerNameSnapshot ?? 'Walk-in'} · '
            '${MoneyAmount.formatPkrFromMinor(draft.totalMinor)} PKR',
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => widget.onResume(draft),
                child: const Text('Resume'),
              ),
              TextButton(
                onPressed: () async {
                  await ref.read(salesRepositoryProvider).cancelDraft(draft.id);
                  await _reload();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SalesHistoryTab extends ConsumerStatefulWidget {
  const _SalesHistoryTab();

  @override
  ConsumerState<_SalesHistoryTab> createState() => _SalesHistoryTabState();
}

class _SalesHistoryTabState extends ConsumerState<_SalesHistoryTab> {
  List<SaleRow> _sales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final rows = await ref
        .read(salesRepositoryProvider)
        .listSales(status: SaleStatus.completed, limit: 100);
    if (!mounted) {
      return;
    }
    setState(() {
      _sales = rows;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_sales.isEmpty) {
      return const Center(child: Text('No completed sales yet'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _sales.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final sale = _sales[index];
        return ListTile(
          title: Text(sale.saleNumber),
          subtitle: Text(
            '${sale.customerNameSnapshot ?? 'Walk-in'} · '
            '${MoneyAmount.formatPkrFromMinor(sale.totalMinor)} PKR',
          ),
          onTap: () => _openDetail(sale),
        );
      },
    );
  }

  Future<void> _openDetail(SaleRow sale) async {
    final sales = ref.read(salesRepositoryProvider);
    final items = await sales.listSaleItems(sale.id);
    final payments = await sales.listSalePayments(sale.id);
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sale.saleNumber),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...items.map(
                (i) => Text(
                  '${i.productNameSnapshot} × ${i.quantityBase} — '
                  '${MoneyAmount.formatPkrFromMinor(i.lineTotalMinor)} PKR',
                ),
              ),
              const Divider(),
              ...payments.map(
                (p) => Text(
                  'Paid ${MoneyAmount.formatPkrFromMinor(p.amountMinor)} PKR (${p.paymentMethod})',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (items.any((i) => i.quantityReturnedBase < i.quantityBase))
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _returnFullSale(sale, items);
              },
              child: const Text('Return all'),
            ),
        ],
      ),
    );
  }

  Future<void> _returnFullSale(SaleRow sale, List<SaleItemRow> items) async {
    final lines = <SaleReturnLineInput>[];
    for (final item in items) {
      final remaining = item.quantityBase - item.quantityReturnedBase;
      if (remaining > 0) {
        lines.add(
          SaleReturnLineInput(saleItemId: item.id, quantityBase: remaining),
        );
      }
    }
    if (lines.isEmpty) {
      return;
    }
    try {
      await ref
          .read(salesRepositoryProvider)
          .returnSale(
            saleId: sale.id,
            idempotencyKey: const Uuid().v4(),
            reason: 'Customer return',
            lines: lines,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Return recorded')));
      await _reload();
    } on SalesConflictException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }
}
