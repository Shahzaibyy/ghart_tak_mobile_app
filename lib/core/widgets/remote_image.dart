import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Remote photo, always cached, masked to the card radius.
class RemoteImage extends StatelessWidget {
  /// Creates an image for [url].
  const new({required this.url, this.radius = 16, super.key});

  /// Absolute image URL.
  final String url;

  /// Clip radius.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final wash = dark ? AppColors.darkLine : AppColors.line;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, _) => ColoredBox(color: wash),
        errorWidget: (_, _, _) => ColoredBox(
          color: wash,
          child: Icon(
            GhIcons.image,
            color: dark ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
