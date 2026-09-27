import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:flutter/material.dart';

/// Circular identity. Initials use a terracotta-to-peach gradient.
class GhAvatar extends StatelessWidget {
  /// Creates an avatar for [name].
  const new({
    required this.name,
    this.photoUrl,
    this.online = false,
    this.size = 44,
    super.key,
  });

  /// Display name used for initials.
  final String name;

  /// Photo, when the person has one.
  final String? photoUrl;

  /// Draws the online dot when true.
  final bool online;

  /// Diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ring = dark ? AppColors.darkLine : AppColors.line;
    final canvas = dark ? AppColors.darkBackground : AppColors.background;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ring, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.5),
              child: _Face(name: name, photoUrl: photoUrl),
            ),
          ),
          if (online)
            Positioned(
              right: -1,
              bottom: -1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: canvas,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                    child: SizedBox(width: 8, height: 8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const new({required this.name, required this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final photo = photoUrl;
    if (photo != null) {
      return ClipOval(child: RemoteImage(url: photo, radius: 999));
    }
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.peach],
        ),
      ),
      child: Center(
        child: Text(
          initialsFor(name),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.surface,
          ),
        ),
      ),
    );
  }
}

/// Two-letter initials from [name].
String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'G';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}
