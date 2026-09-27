/// A delivery offered to a rider.
class RiderTask {
  /// Creates a task.
  const new({
    required this.id,
    required this.title,
    required this.kind,
    required this.pickup,
    required this.pickupDetail,
    required this.dropoff,
    required this.dropoffDetail,
    required this.customerName,
    required this.payoutRupees,
    required this.bonusRupees,
    required this.orderAmount,
    required this.etaMinutes,
    required this.distanceKm,
    required this.pickupKm,
    required this.items,
    required this.orderCode,
    required this.paymentLabel,
    required this.prepaid,
    required this.bag,
  });

  /// Task id.
  final String id;

  /// Store or errand name.
  final String title;

  /// Food, mart, pharmacy, or errand.
  final String kind;

  /// Pickup headline.
  final String pickup;

  /// Street line for pickup.
  final String pickupDetail;

  /// Drop-off headline.
  final String dropoff;

  /// Street line for drop-off.
  final String dropoffDetail;

  /// Customer first name and family name.
  final String customerName;

  /// What the rider earns.
  final int payoutRupees;

  /// Peak bonus included in the payout.
  final int bonusRupees;

  /// What the customer paid for the goods.
  final int orderAmount;

  /// Expected minutes.
  final int etaMinutes;

  /// Full trip length.
  final double distanceKm;

  /// Distance to the pickup.
  final double pickupKm;

  /// Short item summary.
  final String items;

  /// Order reference shown to the rider.
  final String orderCode;

  /// How the customer is paying.
  final String paymentLabel;

  /// Whether the goods are already paid.
  final bool prepaid;

  /// Bag the rider should carry.
  final String bag;
}

/// What the rider is doing right now.
sealed class RiderPhase {
  const new();
}

/// Waiting for a task, or offline.
final class Waiting extends RiderPhase {
  /// Creates the waiting phase.
  const new();
}

/// An offer is counting down.
final class Offering extends RiderPhase {
  /// Creates an offer.
  const new({required this.task, required this.secondsLeft});

  /// Task being offered.
  final RiderTask task;

  /// Seconds before the offer expires.
  final int secondsLeft;
}

/// The offer timer ran out. The rider stays online.
final class OfferExpired extends RiderPhase {
  /// Creates an expired offer.
  const new(this.task);

  /// Task that was missed.
  final RiderTask task;
}

/// Pickup or the ride to the customer.
sealed class TripLeg {
  const new();
}

/// Rider is going to the store.
final class ToPickup extends TripLeg {
  /// Creates the pickup leg.
  const new();
}

/// Rider has the goods and is going to the customer.
final class ToDropoff extends TripLeg {
  /// Creates the drop-off leg.
  const new();
}

/// The rider accepted and is on the trip.
final class Riding extends RiderPhase {
  /// Creates the active trip.
  const new(this.task, {this.leg = const ToPickup()});

  /// Task in progress.
  final RiderTask task;

  /// Pickup, then drop-off.
  final TripLeg leg;
}
