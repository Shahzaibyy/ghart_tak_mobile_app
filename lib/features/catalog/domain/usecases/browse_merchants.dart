import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/domain/repositories/catalog_repository.dart';

/// Loads the merchant directory.
class BrowseMerchants {
  /// Creates a use case over the catalog.
  const new(this._catalog);

  final CatalogRepository _catalog;

  /// Fetches merchants.
  Future<Result<List<Merchant>>> call() => _catalog.listMerchants();
}
