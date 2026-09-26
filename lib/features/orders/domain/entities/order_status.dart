/// Order lifecycle. UI switches on this type exhaustively.
sealed class OrderStatus {
  const new();
}

/// The customer submitted the order.
final class Placed extends OrderStatus {
  /// Creates the placed status.
  const new();
}

/// A rider accepted the task.
final class Accepted extends OrderStatus {
  /// Creates the accepted status.
  const new();
}

/// The rider has the goods.
final class PickedUp extends OrderStatus {
  /// Creates the picked-up status.
  const new();
}

/// The task was completed.
final class Delivered extends OrderStatus {
  /// Creates the delivered status.
  const new();
}

/// The task was cancelled.
final class Cancelled extends OrderStatus {
  /// Creates the cancelled status.
  const new();
}

const Map<String, OrderStatus> _statuses = {
  'placed': Placed(),
  'accepted': Accepted(),
  'picked_up': PickedUp(),
  'delivered': Delivered(),
  'cancelled': Cancelled(),
};

/// Parses the API status string once.
OrderStatus parseOrderStatus(String raw) {
  final status = _statuses[raw];
  if (status == null) {
    throw const FormatException('Unknown order status');
  }
  return status;
}

/// Customer-facing label for [status].
String orderStatusLabel(OrderStatus status) {
  return switch (status) {
    Placed() => 'Order placed',
    Accepted() => 'Rider on the way to pickup',
    PickedUp() => 'On the way to you',
    Delivered() => 'Delivered',
    Cancelled() => 'Cancelled',
  };
}
