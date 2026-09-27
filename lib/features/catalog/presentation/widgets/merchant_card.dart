import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:flutter/material.dart';

/// Featured merchant. The photo is 4:3 and clipped to the card.
class MerchantCard extends StatefulWidget {
  /// Creates a card that opens [merchant].
  const new({required this.merchant, required this.onTap, super.key});

  /// Store to show.
  final Merchant merchant;

  /// Opens the store.
  final VoidCallback onTap;

  @override
  State<MerchantCard> createState() => _MerchantCardState();
}

class _MerchantCardState extends State<MerchantCard> {
  var _saved = false;

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;
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
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Photo(
                merchant: merchant,
                saved: _saved,
                onSave: () => setState(() => _saved = !_saved),
              ),
              _Copy(merchant: merchant),
            ],
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const new({
    required this.merchant,
    required this.saved,
    required this.onSave,
  });

  final Merchant merchant;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(url: merchant.photoUrl, radius: 0),
          Positioned(
            left: 12,
            top: 12,
            child: _Glass(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(GhIcons.starFill, size: 12, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    '${merchant.rating} (${merchant.ratingCount})',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: _Glass(
              child: InkWell(
                onTap: onSave,
                child: Icon(
                  saved ? GhIcons.heartFill : GhIcons.heart,
                  size: 16,
                  color: saved ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: _Glass(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(GhIcons.clock, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    merchant.etaSpan,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: child,
      ),
    );
  }
}

class _Copy extends StatelessWidget {
  const new({required this.merchant});

  final Merchant merchant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${merchant.name} · ${merchant.area}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 8),
              _Badge(label: merchant.badge),
            ],
          ),
          const SizedBox(height: 4),
          Text(merchant.blurb, style: Theme.of(context).textTheme.bodySmall),
          if (merchant.perk.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              merchant.perk,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${_fee(merchant)} · Min ${rupees(merchant.minOrderRupees)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

String _fee(Merchant merchant) {
  if (merchant.deliveryFeeRupees == 0) return 'Free delivery';
  return '${rupees(merchant.deliveryFeeRupees)} delivery';
}

class _Badge extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.success,
          ),
        ),
      ),
    );
  }
}
