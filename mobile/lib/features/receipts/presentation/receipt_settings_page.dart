import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_mobile/app/providers/receipt_providers.dart';
import 'package:pos_mobile/app/theme/app_spacing.dart';
import 'package:pos_mobile/database/app_database.dart';

class ReceiptSettingsPage extends ConsumerStatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  ConsumerState<ReceiptSettingsPage> createState() =>
      _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends ConsumerState<ReceiptSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _taxId;
  late final TextEditingController _header;
  late final TextEditingController _footer;
  late final TextEditingController _currency;
  late final TextEditingController _prefix;
  late final TextEditingController _seqStart;
  int _paperWidth = 58;
  bool _showCustomer = true;
  bool _showPayments = true;
  bool _showSku = false;
  int _copies = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _address = TextEditingController();
    _phone = TextEditingController();
    _taxId = TextEditingController();
    _header = TextEditingController();
    _footer = TextEditingController();
    _currency = TextEditingController();
    _prefix = TextEditingController();
    _seqStart = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final row = await ref.read(receiptSettingsRepositoryProvider).getSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _name.text = row.businessDisplayName ?? '';
      _address.text = row.businessAddress ?? '';
      _phone.text = row.businessPhone ?? '';
      _taxId.text = row.taxRegistrationId ?? '';
      _header.text = row.headerText ?? '';
      _footer.text = row.footerText ?? '';
      _currency.text = row.currencyDisplay;
      _prefix.text = row.invoicePrefix;
      _seqStart.text = row.invoiceSequenceStart.toString();
      _paperWidth = row.paperWidthMm;
      _showCustomer = row.showCustomerDetails;
      _showPayments = row.showPaymentBreakdown;
      _showSku = row.showItemSku;
      _copies = row.defaultCopyCount;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _taxId.dispose();
    _header.dispose();
    _footer.dispose();
    _currency.dispose();
    _prefix.dispose();
    _seqStart.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final seq = int.tryParse(_seqStart.text.trim()) ?? 1;
    await ref
        .read(receiptSettingsRepositoryProvider)
        .updateSettings(
          ReceiptSettingsCompanion(
            businessDisplayName: Value(
              _name.text.trim().isEmpty ? null : _name.text.trim(),
            ),
            businessAddress: Value(
              _address.text.trim().isEmpty ? null : _address.text.trim(),
            ),
            businessPhone: Value(
              _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            ),
            taxRegistrationId: Value(
              _taxId.text.trim().isEmpty ? null : _taxId.text.trim(),
            ),
            headerText: Value(
              _header.text.trim().isEmpty ? null : _header.text.trim(),
            ),
            footerText: Value(
              _footer.text.trim().isEmpty ? null : _footer.text.trim(),
            ),
            currencyDisplay: Value(
              _currency.text.trim().isEmpty ? 'PKR' : _currency.text.trim(),
            ),
            invoicePrefix: Value(
              _prefix.text.trim().isEmpty ? 'INV' : _prefix.text.trim(),
            ),
            invoiceSequenceStart: Value(seq < 1 ? 1 : seq),
            paperWidthMm: Value(_paperWidth),
            showCustomerDetails: Value(_showCustomer),
            showPaymentBreakdown: Value(_showPayments),
            showItemSku: Value(_showSku),
            defaultCopyCount: Value(_copies.clamp(1, 5)),
          ),
        );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Receipt settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Receipt settings',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Business name'),
              ),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _taxId,
                decoration: const InputDecoration(
                  labelText: 'Registration / tax ID (optional)',
                ),
              ),
              TextFormField(
                controller: _header,
                decoration: const InputDecoration(labelText: 'Header text'),
              ),
              TextFormField(
                controller: _footer,
                decoration: const InputDecoration(labelText: 'Footer text'),
              ),
              TextFormField(
                controller: _currency,
                decoration: const InputDecoration(labelText: 'Currency label'),
              ),
              const Divider(),
              TextFormField(
                controller: _prefix,
                decoration: const InputDecoration(
                  labelText: 'Invoice prefix',
                  helperText: 'New numbers use INV-YYYY-######; sequence does not reset yearly.',
                ),
              ),
              TextFormField(
                controller: _seqStart,
                decoration: const InputDecoration(
                  labelText: 'Invoice sequence start (new businesses)',
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<int>(
                value: _paperWidth,
                decoration: const InputDecoration(labelText: 'Paper width'),
                items: const [
                  DropdownMenuItem(value: 58, child: Text('58 mm')),
                  DropdownMenuItem(value: 80, child: Text('80 mm')),
                ],
                onChanged: (v) => setState(() => _paperWidth = v ?? 58),
              ),
              SwitchListTile(
                title: const Text('Show customer on receipt'),
                value: _showCustomer,
                onChanged: (v) => setState(() => _showCustomer = v),
              ),
              SwitchListTile(
                title: const Text('Show payment breakdown'),
                value: _showPayments,
                onChanged: (v) => setState(() => _showPayments = v),
              ),
              SwitchListTile(
                title: const Text('Show item SKU'),
                value: _showSku,
                onChanged: (v) => setState(() => _showSku = v),
              ),
              DropdownButtonFormField<int>(
                value: _copies,
                decoration: const InputDecoration(
                  labelText: 'Default print copies',
                ),
                items: List.generate(
                  5,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                ),
                onChanged: (v) => setState(() => _copies = v ?? 1),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
