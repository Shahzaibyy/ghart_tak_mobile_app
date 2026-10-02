import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/errors/failure.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/network/dio_exception_mapper.dart';
import 'package:attock_xpress/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:dio/dio.dart';

/// Catalog backed by `GET /merchants` + `/catalog` for the demo zone.
class CatalogRepositoryImpl implements CatalogRepository {
  /// Creates the repository.
  const new(this._remote, {this.zoneId = DemoConfig.defaultZoneId});

  final CatalogRemoteDataSource _remote;

  /// Zone used for the customer home feed.
  final String zoneId;

  @override
  Future<Result<List<Merchant>>> listMerchants() async {
    try {
      final merchants = await _remote.listMerchants(zoneId);
      return Success(merchants);
    } on DioException catch (error) {
      return Err(mapDioException(error));
    } on FormatException {
      return const Err(ServerFailure());
    }
  }
}
