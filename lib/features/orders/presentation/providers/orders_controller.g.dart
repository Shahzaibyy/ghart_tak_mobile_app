// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Order repository.

@ProviderFor(orderRepository)
final orderRepositoryProvider = OrderRepositoryProvider._();

/// Order repository.

final class OrderRepositoryProvider
    extends
        $FunctionalProvider<OrderRepository, OrderRepository, OrderRepository>
    with $Provider<OrderRepository> {
  /// Order repository.
  OrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderRepositoryHash();

  @$internal
  @override
  $ProviderElement<OrderRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrderRepository create(Ref ref) {
    return orderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrderRepository>(value),
    );
  }
}

String _$orderRepositoryHash() => r'96f91abf0200ccc7ad21a288585b82bc427a962e';

/// List-orders use case.

@ProviderFor(listOrders)
final listOrdersProvider = ListOrdersProvider._();

/// List-orders use case.

final class ListOrdersProvider
    extends $FunctionalProvider<ListOrders, ListOrders, ListOrders>
    with $Provider<ListOrders> {
  /// List-orders use case.
  ListOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listOrdersHash();

  @$internal
  @override
  $ProviderElement<ListOrders> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListOrders create(Ref ref) {
    return listOrders(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListOrders value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListOrders>(value),
    );
  }
}

String _$listOrdersHash() => r'1d0aa7bc537ea08d10b0dc09443dc0c453e5f41e';

/// Customer order list.

@ProviderFor(OrdersController)
final ordersControllerProvider = OrdersControllerProvider._();

/// Customer order list.
final class OrdersControllerProvider
    extends $AsyncNotifierProvider<OrdersController, List<Order>> {
  /// Customer order list.
  OrdersControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersControllerHash();

  @$internal
  @override
  OrdersController create() => OrdersController();
}

String _$ordersControllerHash() => r'171bf673f646e3f09213f7f334433bc73317ef4a';

/// Customer order list.

abstract class _$OrdersController extends $AsyncNotifier<List<Order>> {
  FutureOr<List<Order>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Order>>, List<Order>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Order>>, List<Order>>,
              AsyncValue<List<Order>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
