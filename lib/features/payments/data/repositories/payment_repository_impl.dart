import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/payments/data/datasources/payment_remote_data_source.dart';
import 'package:attock_xpress/features/payments/domain/entities/wallet_balance.dart';
import 'package:attock_xpress/features/payments/domain/repositories/payment_repository.dart';
import 'package:dio/dio.dart';

/// [PaymentRepository] that maps transport errors once.
class PaymentRepositoryImpl implements PaymentRepository {
  /// Creates the repository.
  const new(this._remote);

  final PaymentRemoteDataSource _remote;

  @override
  Future<Result<WalletBalance>> readBalance() async {
    try {
      final model = await _remote.readBalance();
      return Success(model.toEntity());
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }
}
