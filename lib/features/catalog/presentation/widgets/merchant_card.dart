import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:flutter/material.dart';

/// Flat merchant card. Photography is 4:3 and clipped to the card.
class MerchantCard extends StatelessWidget {
  /// Creates a card that opens [merchant].
  const new({required this.merchant, required this.onTap, super.key});

  /// Store to show.
  final Merchant merchant;

  /// Opens the store.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final line = dark ? AppColors.darkLine : AppColors.line;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Photo(url: merchant.photoUrl),
              _Copy(merchant: merchant),
            ],
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const new({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: RemoteImage(url: url, radius: 0),
    );
  }
}

class _Copy extends StatelessWidget {
  const new({required this.merchant});

  final Merchant merchant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(merchant.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${merchant.area} · ${merchant.etaMinutes} min',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _Rating(rating: merchant.rating),
        ],
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const new({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          GhIcons.starFill,
          size: 14,
          color: AppColors.gold,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
