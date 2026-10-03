import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_quote.dart';
import 'package:attock_xpress/features/orders/domain/repositories/order_repository.dart';

/// Previews fees via `POST /orders/quote` (no payment, no order row).
class QuoteOrder {
  /// Creates a use case over the order repository.
  const new(this._orders);

  final OrderRepository _orders;

  /// Quotes [draft]. Never send `distance_km` — server prices from lat/lng.
  Future<Result<OrderQuote>> call(OrderDraft draft) => _orders.quote(draft);
}
