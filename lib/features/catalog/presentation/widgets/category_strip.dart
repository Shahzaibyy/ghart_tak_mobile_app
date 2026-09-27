import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/features/catalog/domain/entities/feed_category.dart';
import 'package:flutter/material.dart';

/// Horizontal category chips.
class CategoryStrip extends StatelessWidget {
  /// Creates the strip.
  const new({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  /// Category currently filtering the feed.
  final FeedCategory selected;

  /// Called when a chip is tapped.
  final ValueChanged<FeedCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: homeCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = homeCategories[index];
          return _Chip(
            category: category,
            selected: category.runtimeType == selected.runtimeType,
            onTap: () => onSelected(category),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const new({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final FeedCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = _fill(dark);
    final foreground = _foreground(dark);
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: _border(dark)),
          ),
          child: Row(
            children: [
              Icon(_icon(category), size: 16, color: foreground),
              const SizedBox(width: 6),
              Text(
                feedCategoryLabel(category),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _fill(bool dark) {
    if (!selected) return dark ? AppColors.darkSurface : AppColors.surface;
    return dark ? AppColors.darkPrimary : AppColors.primary;
  }

  Color _foreground(bool dark) {
    if (!selected) return dark ? AppColors.darkText : AppColors.text;
    return dark ? AppColors.darkBackground : AppColors.surface;
  }

  Color _border(bool dark) {
    if (selected) return Colors.transparent;
    return dark ? AppColors.darkLine : AppColors.line;
  }
}

IconData _icon(FeedCategory category) {
  return switch (category) {
    Restaurants() => GhIcons.forkKnife,
    Marts() => GhIcons.shoppingBag,
    Pharmacies() => GhIcons.firstAid,
    Parcels() => GhIcons.package,
    Errands() => GhIcons.bicycle,
  };
}
