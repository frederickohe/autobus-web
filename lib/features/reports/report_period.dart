enum ReportPeriod {
  today('TODAY', 'Today'),
  thisWeek('THIS_WEEK', 'This week'),
  thisMonth('THIS_MONTH', 'This month'),
  thisYear('THIS_YEAR', 'This year'),
  all('ALL', 'All time');

  const ReportPeriod(this.apiValue, this.label);

  final String apiValue;
  final String label;

  DateTime? get startDate {
    final now = DateTime.now();
    switch (this) {
      case ReportPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case ReportPeriod.thisWeek:
        final weekday = now.weekday;
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: weekday - 1));
      case ReportPeriod.thisMonth:
        return DateTime(now.year, now.month, 1);
      case ReportPeriod.thisYear:
        return DateTime(now.year, 1, 1);
      case ReportPeriod.all:
        return null;
    }
  }

  bool includes(DateTime? date) {
    if (date == null) return false;
    final start = startDate;
    if (start == null) return true;
    return !date.isBefore(start);
  }

  static DateTime? parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }
}

String formatReportCurrency(num value, {String symbol = 'GHS'}) {
  final v = value.toDouble();
  if (v >= 1000000) {
    return '$symbol ${(v / 1000000).toStringAsFixed(1)}M';
  }
  if (v >= 1000) {
    return '$symbol ${(v / 1000).toStringAsFixed(1)}K';
  }
  return '$symbol ${v.toStringAsFixed(2)}';
}
