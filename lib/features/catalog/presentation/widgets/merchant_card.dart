import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/core/widgets/remote_image.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:flutter/material.dart';

/// Featured merchant card matching v2 HTML (photo + open tag + rating line).
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
      padding: const EdgeInsets.only(bottom: 12),
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
              SizedBox(
                height: 116,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RemoteImage(url: merchant.photoUrl, radius: 0),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: _Pill(
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
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Material(
                        color: AppColors.surface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => setState(() => _saved = !_saved),
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              _saved ? GhIcons.heartFill : GhIcons.heart,
                              size: 18,
                              color: _saved
                                  ? AppColors.primary
                                  : AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            merchant.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _OpenTag(label: merchant.badge),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      merchant.blurb,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          GhIcons.starFill,
                          size: 14,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${merchant.rating} · ${_fee(merchant)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: child,
      ),
    );
  }
}

class _OpenTag extends StatelessWidget {
  const new({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.success,
                fontSize: 12,
              ),
        ),
      ),
    );
  }
}

String _fee(Merchant merchant) {
  if (merchant.deliveryFeeRupees == 0) return 'Free delivery';
  return '${rupees(merchant.deliveryFeeRupees)} delivery';
}
