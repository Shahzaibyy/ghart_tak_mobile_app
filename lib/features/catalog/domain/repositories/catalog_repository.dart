import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';

/// Merchant browse.
abstract interface class CatalogRepository {
  /// Every merchant the home feed can show.
  Future<Result<List<Merchant>>> listMerchants();
}
