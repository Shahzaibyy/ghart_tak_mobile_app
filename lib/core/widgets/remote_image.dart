import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Remote image that always goes through the disk cache.
class RemoteImage extends StatelessWidget {
  /// Creates an image for [url].
  const new({required this.url, this.size = 48, super.key});

  /// Absolute image URL.
  final String url;

  /// Square size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => SizedBox(width: size, height: size),
        errorWidget: (_, _, _) => SizedBox(
          width: size,
          height: size,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }
}
