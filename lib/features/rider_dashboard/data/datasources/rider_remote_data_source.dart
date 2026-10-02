import 'package:attock_xpress/core/network/api_envelope.dart';
import 'package:attock_xpress/core/utils/money_parse.dart';
import 'package:attock_xpress/features/rider_dashboard/domain/entities/rider_task.dart';
import 'package:dio/dio.dart';

/// HTTP calls for rider availability, offers, tasks, and delivery.
class RiderRemoteDataSource {
  /// Creates a data source over the HTTP client.
  const new(this._dio);

  final Dio _dio;

  /// Updates availability.
  Future<void> setOnline({required bool isOnline}) {
    return _dio.post<void>(
      '/riders/availability',
      data: <String, bool>{'is_online': isOnline},
    );
  }

  /// Publishes the rider GPS fix (for dispatch GEO matching).
  Future<void> updatePosition({
    required double lat,
    required double lng,
  }) {
    return _dio.post<void>(
      '/riders/position',
      data: <String, double>{'lat': lat, 'lng': lng},
    );
  }

  /// Pending offers for this rider.
  Future<List<RiderTask>> listOffers() async {
    final response = await _dio.get<Map<String, dynamic>>('/riders/offers');
    final data = unwrapData<List<dynamic>>(response);
    return [
      for (final row in data)
        if (row is Map) _taskFrom(Map<String, dynamic>.from(row)),
    ];
  }

  /// Active / assigned tasks.
  Future<List<RiderTask>> listTasks() async {
    final response = await _dio.get<Map<String, dynamic>>('/riders/tasks');
    final data = unwrapData<List<dynamic>>(response);
    return [
      for (final row in data)
        if (row is Map) _taskFrom(Map<String, dynamic>.from(row)),
    ];
  }

  /// Accepts an offered task (order id).
  Future<void> acceptTask(String taskId) {
    return _dio.post<void>('/riders/tasks/$taskId/accept');
  }

  /// Rejects an offered task.
  Future<void> rejectTask(String taskId) {
    return _dio.post<void>('/riders/tasks/$taskId/reject');
  }

  /// Marks pickup complete.
  Future<void> pickupTask(String taskId) {
    return _dio.post<void>('/riders/tasks/$taskId/pickup');
  }

  /// Marks the order on the way to the customer.
  Future<void> enrouteTask(String taskId) {
    return _dio.post<void>('/riders/tasks/$taskId/enroute');
  }

  /// Confirms delivery with the customer [otp].
  Future<void> confirmDelivery({
    required String taskId,
    required String otp,
  }) {
    return _dio.post<void>(
      '/riders/tasks/$taskId/deliver',
      data: <String, String>{'otp': otp},
    );
  }

  RiderTask _taskFrom(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['order_id'] ?? json['task_id']) as String?;
    if (id == null) throw const FormatException('Offer missing id');
    final payout = json['rider_earning'] ?? json['payout'] ?? json['earning'];
    final total = json['total'] ?? json['order_amount'] ?? json['item_total'];
    final distance = json['distance_km'];
    final pickup = (json['pickup_address'] as String?) ?? 'Pickup';
    final drop = (json['drop_address'] as String?) ?? 'Drop-off';
    final merchant = (json['merchant_name'] as String?) ??
        (json['title'] as String?) ??
        'Merchant';
    final customer = (json['customer_name'] as String?) ?? 'Customer';
    final items = json['items'];
    var itemSummary = 'Order';
    if (items is List && items.isNotEmpty) {
      final first = items.first;
      if (first is Map && first['item_name'] is String) {
        itemSummary = first['item_name'] as String;
      }
    }
    return RiderTask(
      id: id,
      title: merchant,
      kind: (json['type'] as String?) ?? 'food',
      pickup: merchant,
      pickupDetail: pickup,
      dropoff: customer,
      dropoffDetail: drop,
      customerName: customer,
      payoutRupees: _rupees(payout),
      bonusRupees: 0,
      orderAmount: _rupees(total),
      etaMinutes: 15,
      distanceKm: _double(distance),
      pickupKm: 1,
      items: itemSummary,
      orderCode: id.length > 8 ? id.substring(0, 8) : id,
      paymentLabel: (json['payment_method'] as String?)?.toUpperCase() ?? 'COD',
      prepaid: json['payment_method'] == 'wallet',
      bag: 'Thermal bag',
    );
  }

  int _rupees(Object? raw) {
    return switch (raw) {
      final String s => MoneyParse.rupees(s),
      final num n => n.round(),
      _ => 0,
    };
  }

  double _double(Object? raw) {
    return switch (raw) {
      final String s => double.tryParse(s) ?? 0,
      final num n => n.toDouble(),
      _ => 0,
    };
  }
}
