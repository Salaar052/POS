import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/purchasing_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_enums.dart';
import 'package:uuid/uuid.dart';

class PurchasesPage extends ConsumerWidget {
  const PurchasesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CatalogAccessGate(child: _PurchasesBody());
  }
}

class _PurchasesBody extends ConsumerStatefulWidget {
  const _PurchasesBody();

  @override
  ConsumerState<_PurchasesBody> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<_PurchasesBody> {
  List<PurchaseRow> _purchases = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final rows = await ref
        .read(purchaseRepositoryProvider)
        .listPurchases(limit: 200);
    if (!mounted) {
      return;
    }
    setState(() {
      _purchases = rows;
      _loading = false;
    });
  }

  Future<void> _createDraft() async {
    final suppliers = await ref
        .read(supplierRepositoryProvider)
        .listSuppliers(limit: 200);
    if (!mounted) {
      return;
    }
    String? supplierId;
    if (suppliers.isNotEmpty) {
      supplierId = await showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Select supplier'),
          children: [
            ...suppliers.map(
              (s) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, s.id),
                child: Text(s.name),
              ),
            ),
          ],
        ),
      );
    }
    if (supplierId == null) {
      return;
    }
    final purchase = await ref
        .read(purchaseRepositoryProvider)
        .createDraft(supplierId: supplierId);
    if (!mounted) {
      return;
    }
    await _openDraftEditor(purchase);
    await _reload();
  }

  Future<void> _openDraftEditor(PurchaseRow purchase) async {
    final products = await ref
        .read(purchaseRepositoryProvider)
        .listPurchaseItems(purchase.id);
    if (!mounted) {
      return;
    }
    final addProduct = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Draft ${purchase.purchaseNumber}'),
        content: Text(
          products.isEmpty
              ? 'No items yet. Add a product from catalog in a future editor.'
              : '${products.length} item(s) · '
                    'PKR ${MoneyAmount.formatPkrFromMinor(purchase.totalMinor)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Close'),
          ),
          if (purchase.status == PurchaseStatus.draft.storage)
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Receive'),
            ),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    if (addProduct == true && purchase.status == PurchaseStatus.draft.storage) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Receive purchase?'),
          content: const Text(
            'This will increase inventory and record supplier payable.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Receive'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref
            .read(purchaseRepositoryProvider)
            .receivePurchase(
              purchaseId: purchase.id,
              receiveIdempotencyKey: const Uuid().v4(),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Purchases',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton.icon(
                onPressed: _createDraft,
                icon: const Icon(Icons.add),
                label: const Text('New purchase'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _purchases.isEmpty
                ? const Center(child: Text('No purchases yet.'))
                : ListView.separated(
                    itemCount: _purchases.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = _purchases[index];
                      return ListTile(
                        title: Text(p.purchaseNumber),
                        subtitle: Text(
                          '${p.supplierNameSnapshot} · ${p.status}',
                        ),
                        trailing: Text(
                          MoneyAmount.formatPkrFromMinor(p.totalMinor),
                        ),
                        onTap: () => _openDraftEditor(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
