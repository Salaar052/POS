import 'package:drift/drift.dart';

@DataClassName('ReceiptSettingsRow')
class ReceiptSettings extends Table {
  IntColumn get singletonId => integer()();

  TextColumn get businessDisplayName => text().nullable()();

  TextColumn get businessAddress => text().nullable()();

  TextColumn get businessPhone => text().nullable()();

  TextColumn get taxRegistrationId => text().nullable()();

  TextColumn get headerText => text().nullable()();

  TextColumn get footerText => text().nullable()();

  TextColumn get currencyDisplay => text().withDefault(const Constant('PKR'))();

  TextColumn get invoicePrefix => text().withDefault(const Constant('INV'))();

  IntColumn get invoiceSequenceStart =>
      integer().withDefault(const Constant(1))();

  IntColumn get paperWidthMm => integer().withDefault(const Constant(58))();

  BoolColumn get showLogo => boolean().withDefault(const Constant(false))();

  BoolColumn get showCustomerDetails =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get showPaymentBreakdown =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get showItemSku => boolean().withDefault(const Constant(false))();

  IntColumn get defaultCopyCount => integer().withDefault(const Constant(1))();

  TextColumn get selectedPrinterId => text().nullable()();

  TextColumn get printerConnectionType => text().nullable()();

  TextColumn get printerDisplayName => text().nullable()();

  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {singletonId};
}
