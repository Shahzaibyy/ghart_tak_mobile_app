/// Which earnings range is on screen.
sealed class EarningsPeriod {
  const new();
}

/// Earnings since midnight.
final class TodayEarnings extends EarningsPeriod {
  /// Creates the today range.
  const new();
}

/// Earnings for the current week.
final class WeekEarnings extends EarningsPeriod {
  /// Creates the week range.
  const new();
}

/// Earnings for the current month.
final class MonthEarnings extends EarningsPeriod {
  /// Creates the month range.
  const new();
}

/// One bar in the breakdown.
class EarningBar {
  /// Creates a bar.
  const new({required this.label, required this.amount});

  /// Day or week label.
  final String label;

  /// Rupees.
  final int amount;
}

/// A finished trip in the earnings list.
class PastTrip {
  /// Creates a trip row.
  const new({
    required this.title,
    required this.detail,
    required this.payoutRupees,
    required this.food,
  });

  /// Trip name.
  final String title;

  /// Route and time.
  final String detail;

  /// Rider payout.
  final int payoutRupees;

  /// Food icon when true.
  final bool food;
}

/// Numbers for one earnings range.
class EarningsReport {
  /// Creates a report.
  const new({
    required this.eyebrow,
    required this.total,
    required this.change,
    required this.summary,
    required this.bars,
    required this.peakLabel,
    required this.trips,
  });

  /// "TODAY", "THIS WEEK", or "THIS MONTH".
  final String eyebrow;

  /// Headline amount.
  final int total;

  /// Change versus the previous range.
  final String change;

  /// Supporting line under the total.
  final String summary;

  /// Chart bars.
  final List<EarningBar> bars;

  /// Callout for the tallest bar.
  final String peakLabel;

  /// Recent trips.
  final List<PastTrip> trips;
}

const _trips = [
  PastTrip(
    title: 'Food delivery',
    detail: 'Tandoor House to Peoples Colony · 2:15 PM',
    payoutRupees: 220,
    food: true,
  ),
  PastTrip(
    title: 'Custom errand',
    detail: 'Documents from Attock City to Hazro · Delivered',
    payoutRupees: 340,
    food: false,
  ),
  PastTrip(
    title: 'Mart delivery',
    detail: 'Hazro Mart to Kamra Road · 11:40 AM',
    payoutRupees: 180,
    food: false,
  ),
  PastTrip(
    title: 'Pharmacy',
    detail: 'Hasan Pharmacy to Attock City · 10:15 AM',
    payoutRupees: 260,
    food: false,
  ),
];

/// Preview earnings. Swaps with the range chip.
EarningsReport earningsReport(EarningsPeriod period) {
  return switch (period) {
    TodayEarnings() => const EarningsReport(
      eyebrow: 'TODAY',
      total: 1850,
      change: '+12%',
      summary: '6 completed tasks · 4.5 online hrs',
      bars: [
        EarningBar(label: '8a', amount: 180),
        EarningBar(label: '10a', amount: 260),
        EarningBar(label: '12p', amount: 420),
        EarningBar(label: '2p', amount: 310),
        EarningBar(label: '4p', amount: 680),
      ],
      peakLabel: '4 PM · Rs 680 peak',
      trips: _trips,
    ),
    WeekEarnings() => const EarningsReport(
      eyebrow: 'THIS WEEK',
      total: 3240,
      change: '+18%',
      summary: '28 completed tasks · 14.5 online hrs',
      bars: [
        EarningBar(label: 'Mon', amount: 420),
        EarningBar(label: 'Tue', amount: 380),
        EarningBar(label: 'Wed', amount: 510),
        EarningBar(label: 'Thu', amount: 460),
        EarningBar(label: 'Fri', amount: 290),
        EarningBar(label: 'Sat', amount: 920),
        EarningBar(label: 'Sun', amount: 260),
      ],
      peakLabel: 'Sat · Rs 920 peak',
      trips: _trips,
    ),
    MonthEarnings() => const EarningsReport(
      eyebrow: 'THIS MONTH',
      total: 18460,
      change: '+9%',
      summary: '112 completed tasks · 61 online hrs',
      bars: [
        EarningBar(label: 'W1', amount: 4100),
        EarningBar(label: 'W2', amount: 3860),
        EarningBar(label: 'W3', amount: 4920),
        EarningBar(label: 'W4', amount: 5580),
      ],
      peakLabel: 'Week 4 · Rs 5,580 peak',
      trips: _trips,
    ),
  };
}
