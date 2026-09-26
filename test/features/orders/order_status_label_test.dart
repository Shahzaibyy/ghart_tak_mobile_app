import 'package:attock_xpress/features/orders/domain/entities/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('labels every order status', () {
    expect(orderStatusLabel(const Placed()), 'Order placed');
    expect(
      orderStatusLabel(const Accepted()),
      'Rider on the way to pickup',
    );
    expect(orderStatusLabel(const PickedUp()), 'On the way to you');
    expect(orderStatusLabel(const Delivered()), 'Delivered');
    expect(orderStatusLabel(const Cancelled()), 'Cancelled');
  });
}
