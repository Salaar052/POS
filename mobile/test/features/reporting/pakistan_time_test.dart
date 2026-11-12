import 'package:flutter_test/flutter_test.dart';
import 'package:pos_mobile/features/reporting/domain/pakistan_time.dart';
import 'package:pos_mobile/features/reporting/domain/report_period.dart';

void main() {
  group('Pakistan day boundaries', () {
    test('midnight Pakistan maps to prior UTC evening', () {
      final start = PakistanTime.dayStartMsUtc(year: 2025, month: 6, day: 15);
      final utc = DateTime.fromMillisecondsSinceEpoch(start, isUtc: true);
      expect(utc, DateTime.utc(2025, 6, 14, 19));
    });

    test('one second before Pakistan midnight stays on previous PK day', () {
      final dayStart = PakistanTime.dayStartMsUtc(year: 2024, month: 3, day: 2);
      final oneSecondBefore = dayStart - 1;
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(oneSecondBefore, isUtc: true),
      );
      expect(ymd, (year: 2024, month: 3, day: 1));
    });

    test('exactly Pakistan midnight starts new PK day', () {
      final dayStart = PakistanTime.dayStartMsUtc(year: 2024, month: 3, day: 2);
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(dayStart, isUtc: true),
      );
      expect(ymd, (year: 2024, month: 3, day: 2));
    });

    test('one second after Pakistan midnight', () {
      final dayStart = PakistanTime.dayStartMsUtc(year: 2024, month: 3, day: 2);
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(dayStart + 1, isUtc: true),
      );
      expect(ymd, (year: 2024, month: 3, day: 2));
    });

    test('UTC timestamp on different calendar date than Pakistan', () {
      // 2024-03-01 22:00 UTC = 2024-03-02 03:00 Pakistan
      final ms = DateTime.utc(2024, 3, 1, 22).millisecondsSinceEpoch;
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
      );
      expect(ymd, (year: 2024, month: 3, day: 2));
    });

    test('leap day boundaries', () {
      final start = PakistanTime.dayStartMsUtc(year: 2024, month: 2, day: 29);
      final end = PakistanTime.dayEndMsExclusive(year: 2024, month: 2, day: 29);
      expect(end - start, const Duration(days: 1).inMilliseconds);
    });

    test('year boundary month', () {
      final start = PakistanTime.monthStartMsUtc(year: 2025, month: 1);
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(start, isUtc: true),
      );
      expect(ymd, (year: 2025, month: 1, day: 1));
    });
  });

  group('ReportPeriod presets', () {
    test('today spans exactly one Pakistan day', () {
      final period = ReportPeriod.fromPreset(ReportPeriodPreset.today);
      expect(
        period.endMsExclusive - period.startMsInclusive,
        const Duration(days: 1).inMilliseconds,
      );
    });

    test('yesterday ends before today starts', () {
      final yesterday = ReportPeriod.fromPreset(ReportPeriodPreset.yesterday);
      final today = ReportPeriod.fromPreset(ReportPeriodPreset.today);
      expect(yesterday.endMsExclusive, today.startMsInclusive);
    });

    test('custom single PK day is inclusive through end exclusive', () {
      const y = 2025;
      const m = 7;
      const d = 10;
      final period = ReportPeriod.custom(
        startMsInclusive: PakistanTime.dayStartMsUtc(year: y, month: m, day: d),
        endMsExclusive: PakistanTime.dayEndMsExclusive(
          year: y,
          month: m,
          day: d,
        ),
      );
      final lastMs = period.endMsExclusive - 1;
      expect(lastMs, greaterThanOrEqualTo(period.startMsInclusive));
      final ymd = PakistanTime.pakistanYmd(
        DateTime.fromMillisecondsSinceEpoch(lastMs, isUtc: true),
      );
      expect(ymd, (year: y, month: m, day: d));
    });

    test('custom multi-day range covers both endpoints', () {
      final period = ReportPeriod.custom(
        startMsInclusive: PakistanTime.dayStartMsUtc(
          year: 2025,
          month: 5,
          day: 1,
        ),
        endMsExclusive: PakistanTime.dayEndMsExclusive(
          year: 2025,
          month: 5,
          day: 3,
        ),
      );
      expect(
        period.endMsExclusive - period.startMsInclusive,
        const Duration(days: 3).inMilliseconds,
      );
    });

    test('this month and last month do not overlap', () {
      final thisM = ReportPeriod.fromPreset(ReportPeriodPreset.thisMonth);
      final lastM = ReportPeriod.fromPreset(ReportPeriodPreset.lastMonth);
      expect(lastM.endMsExclusive, lessThanOrEqualTo(thisM.startMsInclusive));
    });
  });
}
