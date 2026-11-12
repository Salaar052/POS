import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/sales_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/products/presentation/catalog_access_gate.dart';
import 'package:pos_mobile/features/sales/domain/sales_enums.dart';
import 'package:pos_mobile/features/sales/domain/sales_exceptions.dart';
import 'package:uuid/uuid.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CatalogAccessGate(child: _CustomersBody());
  }
}

class _CustomersBody extends ConsumerStatefulWidget {
  const _CustomersBody();

  @override
  ConsumerState<_CustomersBody> createState() => _CustomersBodyState();
}

class _CustomersBodyState extends ConsumerState<_CustomersBody> {
  final _searchController = TextEditingController();
  List<CustomerRow> _customers = [];
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
    final rows = await ref
        .read(customerRepositoryProvider)
        .listCustomers(query: _searchController.text, limit: 200);
    if (!mounted) {
      return;
    }
    setState(() {
      _customers = rows;
      _loading = false;
    });
  }

  Future<void> _createCustomer() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true || nameController.text.trim().isEmpty) {
      nameController.dispose();
      phoneController.dispose();
      return;
    }
    try {
      await ref
          .read(customerRepositoryProvider)
          .createCustomer(
            name: nameController.text.trim(),
            phone: phoneController.text.trim(),
          );
      nameController.dispose();
      phoneController.dispose();
      await _reload();
    } on SalesConflictException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _openCustomer(CustomerRow customer) async {
    final repo = ref.read(customerRepositoryProvider);
    final balance = await repo.outstandingBalanceMinor(customer.id);
    final sales = await ref
        .read(salesRepositoryProvider)
        .listSalesForCustomer(customer.id);
    final ledger = await repo.listLedger(customer.id);
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customer.phone != null) Text('Phone: ${customer.phone}'),
              Text(
                'Outstanding: ${MoneyAmount.formatPkrFromMinor(balance)} PKR',
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Recent sales',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...sales
                  .take(5)
                  .map(
                    (s) => Text(
                      '${s.saleNumber} — ${MoneyAmount.formatPkrFromMinor(s.totalMinor)} PKR',
                    ),
                  ),
              const Divider(),
              const Text(
                'Ledger',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...ledger
                  .take(8)
                  .map(
                    (e) => Text(
                      '${e.entryType}: D ${e.debitMinor} / C ${e.creditMinor}'
                      '${e.paymentMethod != null ? ' · ${e.paymentMethod}' : ''}'
                      '${e.referenceNumber != null ? ' · ref ${e.referenceNumber}' : ''}',
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
          if (balance > 0)
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _receivePayment(customer, balance);
              },
              child: const Text('Receive payment'),
            ),
        ],
      ),
    );
  }

  Future<void> _receivePayment(CustomerRow customer, int outstanding) async {
    final amountController = TextEditingController(
      text: MoneyAmount.formatPkrFromMinor(outstanding),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment from ${customer.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount (PKR)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record'),
          ),
        ],
      ),
    );
    if (saved != true) {
      amountController.dispose();
      return;
    }
    int parsed;
    try {
      parsed = MoneyAmount.parsePkrToMinor(amountController.text.trim());
    } catch (_) {
      return;
    }
    amountController.dispose();
    if (parsed <= 0) {
      return;
    }
    try {
      await ref
          .read(customerRepositoryProvider)
          .recordCustomerPayment(
            customerId: customer.id,
            amountMinor: parsed,
            method: SalePaymentMethod.cash,
            idempotencyKey: const Uuid().v4(),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Payment recorded')));
      await _reload();
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
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search customers',
                      ),
                      onSubmitted: (_) => _reload(),
                    ),
                  ),
                  IconButton(
                    onPressed: _reload,
                    icon: const Icon(Icons.search),
                  ),
                  FilledButton(
                    onPressed: _createCustomer,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _customers.isEmpty
                  ? const Center(child: Text('No customers yet'))
                  : ListView.separated(
                      itemCount: _customers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final customer = _customers[index];
                        return ListTile(
                          title: Text(customer.name),
                          subtitle: Text(customer.phone ?? 'No phone'),
                          onTap: () => _openCustomer(customer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
