import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/purchasing_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';
import 'package:pos_mobile/features/purchasing/domain/purchasing_exceptions.dart';

class SuppliersPage extends ConsumerWidget {
  const SuppliersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CatalogAccessGate(child: _SuppliersBody());
  }
}

class _SuppliersBody extends ConsumerStatefulWidget {
  const _SuppliersBody();

  @override
  ConsumerState<_SuppliersBody> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends ConsumerState<_SuppliersBody> {
  final _searchController = TextEditingController();
  List<_SupplierListEntry> _rows = [];
  bool _loading = true;

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
    setState(() => _loading = true);
    final suppliers = await ref
        .read(supplierRepositoryProvider)
        .listSuppliers(query: _searchController.text);
    final ledger = ref.read(supplierLedgerRepositoryProvider);
    final entries = <_SupplierListEntry>[];
    for (final s in suppliers) {
      final balance = await ledger.outstandingBalanceMinor(s.id);
      entries.add(_SupplierListEntry(supplier: s, balanceMinor: balance));
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _rows = entries;
      _loading = false;
    });
  }

  Future<void> _addSupplier() async {
    final name = await _promptName(context, title: 'New supplier');
    if (name == null) {
      return;
    }
    try {
      await ref.read(supplierRepositoryProvider).createSupplier(name: name);
      await _reload();
    } on PurchasingConflictException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Suppliers', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search suppliers',
                  ),
                  onSubmitted: (_) => _reload(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                onPressed: _addSupplier,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                ? const Center(child: Text('No suppliers yet.'))
                : ListView.separated(
                    itemCount: _rows.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final row = _rows[index];
                      return ListTile(
                        title: Text(row.supplier.name),
                        subtitle: Text(
                          row.supplier.phone ?? row.supplier.email ?? '',
                        ),
                        trailing: Text(
                          'PKR ${(row.balanceMinor / 100).toStringAsFixed(2)} due',
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

class _SupplierListEntry {
  const _SupplierListEntry({
    required this.supplier,
    required this.balanceMinor,
  });

  final SupplierRow supplier;
  final int balanceMinor;
}

Future<String?> _promptName(
  BuildContext context, {
  required String title,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Name'),
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
  final trimmed = result?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
