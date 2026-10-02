import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/geo_point.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/map/core/map_constants.dart';
import 'package:attock_xpress/features/map/presentation/desktop_fallback_map.dart';
import 'package:flutter/material.dart';

/// Compact Fateh Jang pin map for the customer home feed (Linux + any
/// platform without the Maps SDK).
class ZoneMerchantsMap extends StatelessWidget {
  /// Creates the preview.
  const new({
    required this.merchants,
    this.height = 180,
    super.key,
  });

  final List<Merchant> merchants;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pins = <DesktopMapMarker>[
      for (final m in merchants)
        if (m.lat != null && m.lng != null)
          DesktopMapMarker(
            point: GeoPoint(lat: m.lat!, lng: m.lng!),
            color: AppColors.primary,
            icon: Icons.restaurant,
          ),
    ];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            DesktopFallbackMap(
              center: MapConstants.zoneCenter,
              zoom: 13.2,
              markers: pins.isEmpty
                  ? [
                      DesktopMapMarker(point: MapConstants.zoneCenter),
                    ]
                  : pins,
            ),
            Positioned(
              left: 12,
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    pins.isEmpty
                        ? 'Fateh Jang'
                        : '${pins.length} kitchens nearby',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
