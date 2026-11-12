import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile/app/providers/database_providers.dart';
import 'package:pos_mobile/data/repositories/reporting_repository.dart';
import 'package:pos_mobile/features/reporting/domain/pakistan_time.dart';
import 'package:pos_mobile/features/reporting/domain/report_period.dart';
import 'package:pos_mobile/features/reporting/domain/reporting_models.dart';

final reportingRepositoryProvider = Provider<ReportingRepository>((ref) {
  return ReportingRepository(ref.watch(databaseRunnerProvider));
});

class ReportPeriodSelection {
  const ReportPeriodSelection({
    required this.preset,
    this.customStartMs,
    this.customEndMsExclusive,
  });

  final ReportPeriodPreset preset;
  final int? customStartMs;
  final int? customEndMsExclusive;

  ReportPeriod resolve() {
    if (preset == ReportPeriodPreset.custom &&
        customStartMs != null &&
        customEndMsExclusive != null) {
      return ReportPeriod.custom(
        startMsInclusive: customStartMs!,
        endMsExclusive: customEndMsExclusive!,
      );
    }
    return ReportPeriod.fromPreset(preset);
  }
}

class ReportPeriodPresetNotifier extends Notifier<ReportPeriodSelection> {
  @override
  ReportPeriodSelection build() =>
      const ReportPeriodSelection(preset: ReportPeriodPreset.today);

  void setPreset(ReportPeriodPreset preset) {
    state = ReportPeriodSelection(preset: preset);
  }

  void setCustomRange({
    required DateTime startPakistan,
    required DateTime endPakistan,
  }) {
    final startYmd = (
      year: startPakistan.year,
      month: startPakistan.month,
      day: startPakistan.day,
    );
    final endYmd = (
      year: endPakistan.year,
      month: endPakistan.month,
      day: endPakistan.day,
    );
    state = ReportPeriodSelection(
      preset: ReportPeriodPreset.custom,
      customStartMs: PakistanTime.dayStartMsUtc(
        year: startYmd.year,
        month: startYmd.month,
        day: startYmd.day,
      ),
      customEndMsExclusive: PakistanTime.dayEndMsExclusive(
        year: endYmd.year,
        month: endYmd.month,
        day: endYmd.day,
      ),
    );
  }
}

final reportPeriodPresetProvider =
    NotifierProvider<ReportPeriodPresetNotifier, ReportPeriodSelection>(
  ReportPeriodPresetNotifier.new,
);

final reportPeriodProvider = Provider<ReportPeriod>((ref) {
  return ref.watch(reportPeriodPresetProvider).resolve();
});

final dashboardSnapshotProvider =
    FutureProvider.autoDispose<DashboardSnapshot>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  ref.watch(databaseRunnerProvider);
  return ref.watch(reportingRepositoryProvider).dashboardSnapshot(period);
});

final salesPeriodMetricsProvider =
    FutureProvider.autoDispose<SalesPeriodMetrics>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  return ref.watch(reportingRepositoryProvider).salesPeriodMetrics(period);
});
