import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:attock_xpress/features/orders/domain/entities/order.dart';
import 'package:attock_xpress/features/orders/domain/repositories/order_repository.dart';
import 'package:dio/dio.dart';

/// [OrderRepository] that maps transport errors once.
class OrderRepositoryImpl implements OrderRepository {
  /// Creates the repository.
  const new(this._remote);

  final OrderRemoteDataSource _remote;

  @override
  Future<Result<List<Order>>> listOrders() async {
    try {
      final models = await _remote.listOrders();
      return Success(models.map((model) => model.toEntity()).toList());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }
}
