import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/order_type_for.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/checkout_controller.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composer for a parcel or a custom errand.
class ErrandScreen extends ConsumerStatefulWidget {
  /// Creates the composer for [category].
  const new({
    required this.category,
    required this.onPlaced,
    super.key,
  });

  /// Parcel or errand.
  final FeedCategory category;

  /// Called with the new order id and title.
  final void Function(String orderId, String title) onPlaced;

  @override
  ConsumerState<ErrandScreen> createState() => _ErrandScreenState();
}

class _ErrandScreenState extends ConsumerState<ErrandScreen> {
  final _note = TextEditingController();
  var _sending = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = feedCategoryLabel(widget.category);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _prompt(widget.category),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'A rider in Attock picks it up and brings it home.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What should we do?',
              hintText: 'Pickup, drop-off, and anything the rider should know',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          GhButton(
            label: _sending ? 'Sending' : 'Request rider · Rs 120',
            onPressed: _sending ? null : () => _send(title),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String title) async {
    final note = _note.text.trim();
    if (note.length < 8) {
      setState(() => _error = 'Add a little more detail for the rider.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await ref.read(placeOrderProvider).call(
      OrderDraft(
        title: title,
        type: orderTypeFor(widget.category),
        deliveryFee: 120,
        photoUrl: null,
        paymentLabel: 'Cash on delivery',
      ),
    );
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        widget.onPlaced(value.id, value.title);
      case Err(:final failure):
        setState(() {
          _sending = false;
          _error = failure.message;
        });
    }
  }
}

String _prompt(FeedCategory category) {
  return switch (category) {
    Parcels() => 'Send a parcel',
    Errands() => 'Run an errand',
    Restaurants() || Marts() || Pharmacies() => 'Tell us what you need',
  };
}
