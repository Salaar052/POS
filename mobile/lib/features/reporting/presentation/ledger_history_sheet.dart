import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/reporting_providers.dart';
import 'package:pos_mobile/app/providers/purchasing_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/features/catalog/domain/money_amount.dart';
import 'package:pos_mobile/features/reporting/domain/report_period.dart';
import 'package:pos_mobile/features/reporting/domain/reporting_models.dart';
import 'package:pos_mobile/features/reporting/presentation/sale_detail_dialog.dart';

enum LedgerHistoryParty { customer, supplier }

Future<void> showLedgerHistorySheet({
  required BuildContext context,
  required WidgetRef ref,
  required LedgerHistoryParty party,
  required String partyId,
  required String partyName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _LedgerHistorySheetBody(
        scrollController: scrollController,
        party: party,
        partyId: partyId,
        partyName: partyName,
      ),
    ),
  );
}

class _LedgerHistorySheetBody extends ConsumerStatefulWidget {
  const _LedgerHistorySheetBody({
    required this.scrollController,
    required this.party,
    required this.partyId,
    required this.partyName,
  });

  final ScrollController scrollController;
  final LedgerHistoryParty party;
  final String partyId;
  final String partyName;

  @override
  ConsumerState<_LedgerHistorySheetBody> createState() =>
      _LedgerHistorySheetBodyState();
}

class _LedgerHistorySheetBodyState
    extends ConsumerState<_LedgerHistorySheetBody> {
  final List<LedgerHistoryEntry> _entries = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _offset = 0;
  int _authoritativeBalance = 0;
  int _openingBalance = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _entries.clear();
        _offset = 0;
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final period = ref.read(reportPeriodProvider);
      final repo = ref.read(reportingRepositoryProvider);
      final LedgerHistoryPage page;
      if (widget.party == LedgerHistoryParty.customer) {
        page = await repo.customerLedgerHistory(
          customerId: widget.partyId,
          period: period,
          offset: _offset,
        );
      } else {
        page = await repo.supplierLedgerHistory(
          supplierId: widget.partyId,
          period: period,
          offset: _offset,
        );
      }
      if (!mounted) {
        return;
      }
      setState(() {
        if (reset) {
          _entries
            ..clear()
            ..addAll(page.entries);
        } else {
          _entries.addAll(page.entries);
        }
        _hasMore = page.hasMore;
        _offset = page.nextOffset;
        _authoritativeBalance = page.authoritativeBalanceMinor;
        _openingBalance = page.openingBalanceMinor;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  String _formatWhen(int ms) {
    final utc = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    final local = utc.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openLinked(LedgerHistoryEntry entry) async {
    if (entry.linkedSaleId != null) {
      await showSaleDetailDialog(context, ref, entry.linkedSaleId!);
      return;
    }
    if (entry.linkedPurchaseId != null) {
      final purchase = await ref
          .read(purchaseRepositoryProvider)
          .getPurchaseById(entry.linkedPurchaseId!);
      if (!mounted || purchase == null) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(purchase.purchaseNumber),
          content: Text(
            'Total: ${MoneyAmount.formatPkrFromMinor(purchase.totalMinor)} PKR',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = ref.watch(reportPeriodProvider);
    ref.listen(reportPeriodPresetProvider, (_, __) => _load(reset: true));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.partyName, style: theme.textTheme.titleLarge),
              Text(
                '${widget.party == LedgerHistoryParty.customer ? 'Customer' : 'Supplier'} ledger · ${period.label}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Current balance: '
                '${MoneyAmount.formatPkrFromMinor(_authoritativeBalance)} PKR',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                'Opening balance (before period): '
                '${MoneyAmount.formatPkrFromMinor(_openingBalance)} PKR',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(child: Center(child: Text(_error!)))
        else if (_entries.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No ledger transactions in this period.'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _entries.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _entries.length) {
                  return TextButton(
                    onPressed: _loadingMore ? null : () => _load(reset: false),
                    child: _loadingMore
                        ? const CircularProgressIndicator()
                        : const Text('Load more'),
                  );
                }
                final entry = _entries[index];
                final navigable =
                    entry.linkedSaleId != null ||
                    entry.linkedPurchaseId != null;
                return ListTile(
                  title: Text(entry.typeLabel),
                  subtitle: Text(
                    '${_formatWhen(entry.createdAtMs)}\n'
                    '${entry.referenceLabel}',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (entry.debitMinor > 0)
                        Text(
                          'Dr ${MoneyAmount.formatPkrFromMinor(entry.debitMinor)}',
                        ),
                      if (entry.creditMinor > 0)
                        Text(
                          'Cr ${MoneyAmount.formatPkrFromMinor(entry.creditMinor)}',
                        ),
                      Text(
                        'Bal ${MoneyAmount.formatPkrFromMinor(entry.balanceAfterMinor)}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                  onTap: navigable ? () => _openLinked(entry) : null,
                );
              },
            ),
          ),
      ],
    );
  }
}
