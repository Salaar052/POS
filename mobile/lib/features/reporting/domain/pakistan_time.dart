/// Pakistan business calendar (Asia/Karachi, UTC+05:00, no DST).
abstract final class PakistanTime {
  static const offset = Duration(hours: 5);

  static DateTime nowPakistan() {
    return DateTime.now().toUtc().add(offset);
  }

  /// Start of [year]-[month]-[day] in Pakistan, as UTC epoch milliseconds.
  static int dayStartMsUtc({
    required int year,
    required int month,
    required int day,
  }) {
    final pakistanMidnightUtc = DateTime.utc(year, month, day).subtract(offset);
    return pakistanMidnightUtc.millisecondsSinceEpoch;
  }

  /// Exclusive end of the same Pakistan calendar day.
  static int dayEndMsExclusive({
    required int year,
    required int month,
    required int day,
  }) {
    return dayStartMsUtc(year: year, month: month, day: day) +
        const Duration(days: 1).inMilliseconds;
  }

  static ({int year, int month, int day}) pakistanYmd(DateTime utc) {
    final pk = utc.add(offset);
    return (year: pk.year, month: pk.month, day: pk.day);
  }

  static int monthStartMsUtc({required int year, required int month}) {
    return dayStartMsUtc(year: year, month: month, day: 1);
  }

  static int monthEndMsExclusive({required int year, required int month}) {
    final nextMonth = month == 12
        ? (year: year + 1, month: 1)
        : (year: year, month: month + 1);
    return monthStartMsUtc(year: nextMonth.year, month: nextMonth.month);
  }
}
