import 'dart:async';

import 'package:attock_xpress/core/config/demo_config.dart';
import 'package:attock_xpress/core/errors/result.dart';
import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:attock_xpress/features/catalog/domain/order_type_for.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/checkout_controller.dart';
import 'package:attock_xpress/features/orders/domain/entities/order_draft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _chips = ['Keys drop-off', 'Legal papers', 'Lunchbox'];
const _quoteRupees = 120;

/// What the composer is waiting on.
sealed class ErrandQuote {
  const new();
}

/// The customer has not asked for a price yet.
final class Unquoted extends ErrandQuote {
  /// Creates the unquoted step.
  const new();
}

/// A price is on screen and can be confirmed.
final class Quoted extends ErrandQuote {
  /// Creates a quote.
  const new(this.rupees);

  /// Estimated rider fee.
  final int rupees;
}

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
  ErrandQuote _quote = const Unquoted();
  String _pickup = 'Mall Road, Attock City';
  String _dropoff = 'House 18, Street 4, Peoples Colony';

  @override
  void initState() {
    super.initState();
    _note.addListener(_onNote);
  }

  @override
  void dispose() {
    _note
      ..removeListener(_onNote)
      ..dispose();
    super.dispose();
  }

  void _onNote() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(feedCategoryLabel(widget.category))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            'DIRECT DISPATCH',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'What do you need?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Describe a pickup, a purchase, or a delivery.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _note,
            minLines: 4,
            maxLines: 6,
            maxLength: 300,
            decoration: const InputDecoration(
              hintText: 'Drop a lunchbox, or pick up dry cleaning',
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (final chip in _chips)
                ActionChip(
                  label: Text(chip),
                  onPressed: () => _note.text = chip,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Place(
            title: 'Pickup location',
            value: _pickup,
            onTap: () => _setPlace(pickup: true),
          ),
          const SizedBox(height: 8),
          _Place(
            title: 'Drop location',
            value: _dropoff,
            onTap: () => _setPlace(pickup: false),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(GhIcons.camera),
            title: const Text('Add photo'),
            subtitle: const Text('Optional, so the rider can match the stop'),
            onTap: () => _sheet('Photo attach is a preview'),
          ),
          const SizedBox(height: 8),
          Text(
            'Rider guarantee up to Rs 25,000 on tracked errands.',
            style: Theme.of(context).textTheme.bodySmall,
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
          const SizedBox(height: 20),
          GhButton(
            label: _label(),
            onPressed: _sending ? null : _primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Average rider assignment: 4 minutes',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _label() {
    final quote = _quote;
    if (_sending) return 'Sending';
    return switch (quote) {
      Unquoted() => 'Get a price estimate',
      Quoted(rupees: final fee) => 'Request rider · ${rupees(fee)}',
    };
  }

  void _primary() {
    final quote = _quote;
    switch (quote) {
      case Unquoted():
        _estimate();
      case Quoted():
        unawaited(_send());
    }
  }

  void _estimate() {
    if (_note.text.trim().length < 8) {
      setState(() => _error = 'Add a little more detail for the rider.');
      return;
    }
    setState(() {
      _error = null;
      _quote = const Quoted(_quoteRupees);
    });
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final result = await ref.read(placeOrderProvider).call(
      OrderDraft(
        title: feedCategoryLabel(widget.category),
        type: orderTypeFor(widget.category),
        zoneId: DemoConfig.defaultZoneId,
        drop: const GeoPoint(
          lat: DemoConfig.demoDropLat,
          lng: DemoConfig.demoDropLng,
        ),
        dropAddress: DemoConfig.demoDropAddress,
        paymentMethod: 'cod',
        clientRequestId: 'req-errand-${DateTime.now().millisecondsSinceEpoch}',
        items: const [],
        deliveryFee: _quoteRupees,
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

  void _setPlace({required bool pickup}) {
    final next = pickup ? 'Hazro Bazaar' : 'Kamra Road, Attock';
    setState(() {
      if (pickup) {
        _pickup = next;
      } else {
        _dropoff = next;
      }
    });
  }

  void _sheet(String message) {
    unawaited(
      showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Text(message),
        );
      },
    ),
    );
  }
}

class _Place extends StatelessWidget {
  const new({required this.title, required this.value, required this.onTap});

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(GhIcons.mapPin, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Text('Set'),
      onTap: onTap,
    );
  }
}
