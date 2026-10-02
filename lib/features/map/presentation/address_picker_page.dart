import 'dart:async';

import 'package:attock_xpress/core/config/app_config.dart';
import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/data/geo_api.dart';
import 'package:attock_xpress/features/map/presentation/bhook_map.dart';
import 'package:attock_xpress/features/map/presentation/map_session.dart';
import 'package:attock_xpress/features/map/presentation/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Result of the address picker (pin + editable label).
class PickedAddress {
  /// Creates a picked address.
  const new({required this.point, required this.label});

  /// Map pin.
  final GeoPoint point;

  /// Label the user confirmed (may include landmark text).
  final String label;
}

/// Centre-pin address picker. Reverse-geocodes only on map idle (debounced).
class AddressPickerPage extends ConsumerStatefulWidget {
  /// Creates the picker.
  const new({
    this.initial = MapConstants.attockCenter,
    this.initialLabel,
    super.key,
  });

  /// Starting camera centre.
  final GeoPoint initial;

  /// Optional seed label.
  final String? initialLabel;

  @override
  ConsumerState<AddressPickerPage> createState() => _AddressPickerPageState();
}

class _AddressPickerPageState extends ConsumerState<AddressPickerPage> {
  final _session = MapSession();
  final _label = TextEditingController();
  final _search = TextEditingController();
  Timer? _debounce;
  GeoPoint? _picked;
  var _loading = false;
  List<PlaceSuggestion> _hits = const [];

  @override
  void initState() {
    super.initState();
    _label.text = widget.initialLabel ?? '';
    _picked = widget.initial;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _label.dispose();
    _search.dispose();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.hasMapboxToken) {
      return Scaffold(
        appBar: AppBar(title: const Text('Set delivery address')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Add ACCESS_TOKEN via --dart-define-from-file=config/dart_defines.json to use the map picker.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          BhookMap(
            center: widget.initial,
            zoom: MapConstants.pickerZoom,
            onReady: (map) => unawaited(_session.attach(map)),
            onMapIdle: _onIdle,
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(
                  Icons.location_pin,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      const BackButton(),
                      Expanded(
                        child: Text(
                          'Delivery pin',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Material(
                    color: dark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    child: TextField(
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => unawaited(_runSearch()),
                      decoration: InputDecoration(
                        hintText: 'Search Attock…',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => unawaited(_runSearch()),
                          icon: const Icon(GhIcons.magnifyingGlass),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_hits.isNotEmpty)
                  Flexible(
                    child: Material(
                      color: dark ? AppColors.darkSurface : AppColors.surface,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _hits.length,
                        itemBuilder: (context, i) {
                          final hit = _hits[i];
                          return ListTile(
                            leading: const Icon(GhIcons.mapPin),
                            title: Text(hit.label),
                            onTap: () => unawaited(_selectHit(hit)),
                          );
                        },
                      ),
                    ),
                  ),
                const Spacer(),
                _Sheet(
                  controller: _label,
                  loading: _loading,
                  onConfirm: _confirm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onIdle() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_reverse());
    });
  }

  Future<void> _reverse() async {
    final point = await _session.cameraCenter();
    if (point == null || !mounted) return;
    setState(() => _loading = true);
    final addr = await ref.read(geoApiProvider).reverse(point);
    if (!mounted) return;
    setState(() {
      _picked = point;
      _label.text = addr;
      _loading = false;
    });
  }

  Future<void> _runSearch() async {
    final q = _search.text.trim();
    if (q.isEmpty) {
      setState(() => _hits = const []);
      return;
    }
    final proximity = _picked ?? widget.initial;
    final hits = await ref.read(geoApiProvider).search(q, proximity: proximity);
    if (!mounted) return;
    setState(() => _hits = hits);
  }

  Future<void> _selectHit(PlaceSuggestion hit) async {
    setState(() {
      _hits = const [];
      _picked = hit.point;
      _label.text = hit.label;
      _search.clear();
    });
    await _session.flyTo(hit.point);
  }

  void _confirm() {
    final point = _picked;
    if (point == null) return;
    final text = _label.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).pop(PickedAddress(point: point, label: text));
  }
}

class _Sheet extends StatelessWidget {
  const new({
    required this.controller,
    required this.loading,
    required this.onConfirm,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [AppShadow.floating],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm address',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Add a house number or landmark — riders use that '
              'more than the pin.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Address',
                suffixIcon: loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            GhButton(label: 'Use this address', onPressed: onConfirm),
          ],
        ),
      ),
    );
  }
}
