import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/queued_action.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/repositories/rider_repository.dart';

/// Desk figures shown on the rider home.
class RiderDesk {
  /// Creates the home snapshot.
  const new({
    required this.todayRupees,
    required this.completed,
    required this.rating,
    required this.listening,
    required this.demand,
    required this.queueNote,
    required this.zones,
  });

  /// Earned so far today.
  final int todayRupees;

  /// Finished trips today.
  final int completed;

  /// Rolling rating.
  final double rating;

  /// Where the rider is listening.
  final String listening;

  /// Demand line under the waiting mark.
  final String demand;

  /// Queue chip.
  final String queueNote;

  /// Surge areas.
  final List<SurgeZone> zones;
}

/// A neighbourhood paying extra right now.
class SurgeZone {
  /// Creates a zone.
  const new({
    required this.name,
    required this.detail,
    required this.extraRupees,
    required this.iconFood,
  });

  /// Place name.
  final String name;

  /// Why it is busy.
  final String detail;

  /// Extra payout.
  final int extraRupees;

  /// Food zone when true, parcel zone otherwise.
  final bool iconFood;
}

const _previewTask = RiderTask(
  id: 'task-tandoor',
  title: 'Tandoor House',
  kind: 'Food delivery',
  pickup: 'Tandoor House · Mall Road',
  pickupDetail: 'Shop 12, Mall Road, Attock City',
  dropoff: 'Peoples Colony',
  dropoffDetail: 'House 18, Street 4, Peoples Colony',
  customerName: 'Ayesha Khan',
  payoutRupees: 220,
  bonusRupees: 40,
  orderAmount: 850,
  etaMinutes: 18,
  distanceKm: 4,
  pickupKm: 1.2,
  items: '1x Chicken karahi, 2x Roghni naan',
  orderCode: 'GT-1842',
  paymentLabel: 'Cash on delivery',
  prepaid: false,
  bag: 'Standard bag',
);

/// Home numbers for the Attock preview.
const RiderDesk previewDesk = RiderDesk(
  todayRupees: 1850,
  completed: 6,
  rating: 4.92,
  listening: 'Attock City & Peoples Colony',
  demand: 'High demand in Attock City · 1.2x boost active',
  queueNote: 'Mall Road queue is moving fast',
  zones: [
    SurgeZone(
      name: 'Hazro Bazaar',
      detail: 'Average pickup under 4 mins',
      extraRupees: 60,
      iconFood: true,
    ),
    SurgeZone(
      name: 'Peoples Colony',
      detail: 'Errands and grocery batch',
      extraRupees: 40,
      iconFood: false,
    ),
  ],
);

/// Local rider desk so the portal can be reviewed without the API.
class SampleRiderRepository implements RiderRepository {
  /// Creates the sample desk.
  const new();

  @override
  Future<Result<Nothing>> setOnline({required bool isOnline}) async {
    return const Success(nothing);
  }

  @override
  Future<Result<Nothing>> confirmDelivery({
    required String taskId,
    required String otp,
  }) async {
    return const Success(nothing);
  }

  @override
  Future<Result<Nothing>> replay(QueuedAction action) async {
    return const Success(nothing);
  }

  @override
  Future<Result<RiderTask?>> peekTask() async => const Success(_previewTask);

  @override
  Future<Result<Nothing>> acceptTask(String taskId) async {
    return const Success(nothing);
  }

  @override
  Future<Result<Nothing>> rejectTask(String taskId) async {
    return const Success(nothing);
  }

  @override
  Future<Result<Nothing>> pickupTask(String taskId) async {
    return const Success(nothing);
  }

  @override
  Future<Result<Nothing>> enrouteTask(String taskId) async {
    return const Success(nothing);
  }

  @override
  Future<Result<Nothing>> pingPosition({
    required double lat,
    required double lng,
  }) async {
    return const Success(nothing);
  }
}
