import 'package:pos_mobile/features/reporting/domain/pakistan_time.dart';

enum ReportPeriodPreset {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  custom,
}

class ReportPeriod {
  const ReportPeriod({
    required this.startMsInclusive,
    required this.endMsExclusive,
    required this.preset,
  });

  final int startMsInclusive;
  final int endMsExclusive;
  final ReportPeriodPreset preset;

  factory ReportPeriod.fromPreset(ReportPeriodPreset preset) {
    final nowPk = PakistanTime.nowPakistan();
    final y = nowPk.year;
    final m = nowPk.month;
    final d = nowPk.day;

    switch (preset) {
      case ReportPeriodPreset.today:
        return ReportPeriod(
          startMsInclusive: PakistanTime.dayStartMsUtc(
            year: y,
            month: m,
            day: d,
          ),
          endMsExclusive: PakistanTime.dayEndMsExclusive(
            year: y,
            month: m,
            day: d,
          ),
          preset: preset,
        );
      case ReportPeriodPreset.yesterday:
        final yesterday = nowPk.subtract(const Duration(days: 1));
        return ReportPeriod(
          startMsInclusive: PakistanTime.dayStartMsUtc(
            year: yesterday.year,
            month: yesterday.month,
            day: yesterday.day,
          ),
          endMsExclusive: PakistanTime.dayEndMsExclusive(
            year: yesterday.year,
            month: yesterday.month,
            day: yesterday.day,
          ),
          preset: preset,
        );
      case ReportPeriodPreset.last7Days:
        final startDay = nowPk.subtract(const Duration(days: 6));
        return ReportPeriod(
          startMsInclusive: PakistanTime.dayStartMsUtc(
            year: startDay.year,
            month: startDay.month,
            day: startDay.day,
          ),
          endMsExclusive: PakistanTime.dayEndMsExclusive(
            year: y,
            month: m,
            day: d,
          ),
          preset: preset,
        );
      case ReportPeriodPreset.last30Days:
        final startDay = nowPk.subtract(const Duration(days: 29));
        return ReportPeriod(
          startMsInclusive: PakistanTime.dayStartMsUtc(
            year: startDay.year,
            month: startDay.month,
            day: startDay.day,
          ),
          endMsExclusive: PakistanTime.dayEndMsExclusive(
            year: y,
            month: m,
            day: d,
          ),
          preset: preset,
        );
      case ReportPeriodPreset.thisMonth:
        return ReportPeriod(
          startMsInclusive: PakistanTime.monthStartMsUtc(year: y, month: m),
          endMsExclusive: PakistanTime.monthEndMsExclusive(year: y, month: m),
          preset: preset,
        );
      case ReportPeriodPreset.lastMonth:
        final last = m == 1
            ? (year: y - 1, month: 12)
            : (year: y, month: m - 1);
        return ReportPeriod(
          startMsInclusive: PakistanTime.monthStartMsUtc(
            year: last.year,
            month: last.month,
          ),
          endMsExclusive: PakistanTime.monthEndMsExclusive(
            year: last.year,
            month: last.month,
          ),
          preset: preset,
        );
      case ReportPeriodPreset.custom:
        throw ArgumentError('Use ReportPeriod.custom for custom ranges');
    }
  }

  factory ReportPeriod.custom({
    required int startMsInclusive,
    required int endMsExclusive,
  }) {
    return ReportPeriod(
      startMsInclusive: startMsInclusive,
      endMsExclusive: endMsExclusive,
      preset: ReportPeriodPreset.custom,
    );
  }

  String get label => switch (preset) {
    ReportPeriodPreset.today => 'Today',
    ReportPeriodPreset.yesterday => 'Yesterday',
    ReportPeriodPreset.last7Days => 'Last 7 days',
    ReportPeriodPreset.last30Days => 'Last 30 days',
    ReportPeriodPreset.thisMonth => 'This month',
    ReportPeriodPreset.lastMonth => 'Last month',
    ReportPeriodPreset.custom => 'Custom range',
  };
}
