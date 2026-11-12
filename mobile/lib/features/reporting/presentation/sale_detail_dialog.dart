import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/sales_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';

Future<void> showSaleDetailDialog(
  BuildContext context,
  WidgetRef ref,
  String saleId,
) async {
  final sale = await ref.read(salesRepositoryProvider).getSaleById(saleId);
  if (!context.mounted || sale == null) {
    return;
  }
  final items = await ref.read(salesRepositoryProvider).listSaleItems(saleId);
  if (!context.mounted) {
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) => _SaleDetailDialog(sale: sale, items: items),
  );
}

class _SaleDetailDialog extends StatelessWidget {
  const _SaleDetailDialog({required this.sale, required this.items});

  final SaleRow sale;
  final List<SaleItemRow> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = sale.completedAtMs == null
        ? '—'
        : DateTime.fromMillisecondsSinceEpoch(
            sale.completedAtMs!,
            isUtc: true,
          ).toLocal().toString();
    return AlertDialog(
      title: Text(sale.invoiceNumber ?? sale.saleNumber),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${sale.status}'),
              Text('Completed: $completed'),
              if (sale.customerNameSnapshot != null)
                Text('Customer: ${sale.customerNameSnapshot}'),
              const SizedBox(height: AppSpacing.md),
              Text('Lines', style: theme.textTheme.titleSmall),
              for (final line in items)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(line.productNameSnapshot),
                  subtitle: Text('Qty ${line.quantityBase}'),
                  trailing: Text(
                    MoneyAmount.formatPkrFromMinor(line.lineTotalMinor),
                  ),
                ),
              const Divider(),
              Text(
                'Total: ${MoneyAmount.formatPkrFromMinor(sale.totalMinor)} PKR',
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
