import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_quote.dart';
import 'package:attock_xpress/features/orders/domain/repositories/order_repository.dart';
import 'package:dio/dio.dart';

/// Live order API. List is a local cache of placed orders (no list endpoint).
class OrderRepositoryImpl implements OrderRepository {
  /// Creates the repository.
  new(this._remote);

  final OrderRemoteDataSource _remote;
  final List<Order> _placed = [];

  @override
  Future<Result<List<Order>>> listOrders() async {
    return Success(List.unmodifiable(_placed));
  }

  @override
  Future<Result<Order>> placeOrder(OrderDraft draft) async {
    try {
      final order = await _remote.placeOrder(draft);
      _placed.removeWhere((o) => o.id == order.id);
      _placed.insert(0, order);
      return Success(order);
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }

  /// Quotes fees for [draft].
  @override
  Future<Result<OrderQuote>> quote(OrderDraft draft) async {
    try {
      return Success(await _remote.quote(draft));
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }

  /// Refreshes one order by id.
  @override
  Future<Result<Order>> getOrder(String id) async {
    try {
      final cached = _placed.where((o) => o.id == id).firstOrNull;
      final order = await _remote.getOrder(
        id,
        title: cached?.title,
        photoUrl: cached?.photoUrl,
      );
      _placed.removeWhere((o) => o.id == id);
      _placed.insert(0, order);
      return Success(order);
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }
}
