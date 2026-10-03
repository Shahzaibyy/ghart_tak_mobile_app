import 'package:attock_xpress/core/icons/gh_icons.dart';
import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/utils/money.dart';
import 'package:attock_xpress/features/catalog/domain/entities/catalog_item.dart';
import 'package:attock_xpress/features/catalog/domain/entities/merchant.dart';
import 'package:attock_xpress/features/catalog/presentation/providers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Swipeable options sheet: portion, add-ons, note, qty.
class ItemOptionsSheet extends ConsumerStatefulWidget {
  /// Creates the sheet for [item] at [merchant].
  const new({required this.merchant, required this.item, super.key});

  /// Store owning the item.
  final Merchant merchant;

  /// Menu item being customized.
  final CatalogItem item;

  @override
  ConsumerState<ItemOptionsSheet> createState() => _ItemOptionsSheetState();
}

class _ItemOptionsSheetState extends ConsumerState<ItemOptionsSheet> {
  var _portion = 1; // 0 half, 1 full
  final _addons = <int>{0};
  var _qty = 1;
  final _note = TextEditingController();

  static const List<({String label, String hint, int delta})> _portions = [
    (label: 'Half', hint: 'Ek bande ke liye', delta: -140),
    (label: 'Full', hint: 'Bhook zyada ho to', delta: 0),
  ];

  static const List<({String label, int price})> _addonList = [
    (label: 'Raita', price: 40),
    (label: 'Salad', price: 30),
    (label: 'Extra kabab', price: 140),
  ];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  int get _unitPrice {
    final base = widget.item.priceRupees + _portions[_portion].delta;
    final extras = _addons.fold<int>(
      0,
      (sum, i) => sum + _addonList[i].price,
    );
    return (base < 0 ? 0 : base) + extras;
  }

  int get _lineTotal => _unitPrice * _qty;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? AppColors.darkBackground : AppColors.background;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final line = dark ? AppColors.darkLine : AppColors.line;
    final muted = dark ? AppColors.darkTextMuted : AppColors.textMuted;
    final height = MediaQuery.sizeOf(context).height * 0.84;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.detail.isEmpty
                                    ? 'Raita aur kachumber ke saath.'
                                    : widget.item.detail,
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(GhIcons.x, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: surface,
                            side: BorderSide(color: line),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _SectionHead(
                      title: 'Portion',
                      tag: 'Required',
                      tagColor: AppColors.error,
                    ),
                    const SizedBox(height: 8),
                    _OptionBox(
                      surface: surface,
                      line: line,
                      children: [
                        for (var i = 0; i < _portions.length; i++)
                          _RadioRow(
                            icon: GhIcons.bowlFood,
                            title: _portions[i].label,
                            subtitle: _portions[i].hint,
                            price: widget.item.priceRupees +
                                _portions[i].delta,
                            selected: _portion == i,
                            onTap: () => setState(() => _portion = i),
                            line: line,
                            muted: muted,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const _SectionHead(
                      title: 'Add-ons',
                      tag: 'Optional',
                    ),
                    const SizedBox(height: 8),
                    _OptionBox(
                      surface: surface,
                      line: line,
                      children: [
                        for (var i = 0; i < _addonList.length; i++)
                          _CheckRow(
                            icon: GhIcons.bowlFood,
                            title: _addonList[i].label,
                            price: _addonList[i].price,
                            selected: _addons.contains(i),
                            onTap: () {
                              setState(() {
                                if (_addons.contains(i)) {
                                  _addons.remove(i);
                                } else {
                                  _addons.add(i);
                                }
                              });
                            },
                            line: line,
                            muted: muted,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Special instructions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _note,
                      decoration: InputDecoration(
                        hintText: 'Kam mirch, extra pyaaz?',
                        prefixIcon: const Icon(GhIcons.fileText, size: 20),
                        filled: true,
                        fillColor: surface,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                          borderSide: BorderSide(color: line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.control),
                          borderSide: BorderSide(color: line),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: surface,
                  border: Border(top: BorderSide(color: line)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.control),
                            border: Border.all(color: line),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: _qty > 1
                                      ? () => setState(() => _qty--)
                                      : null,
                                  child: Icon(
                                    GhIcons.minus,
                                    size: 18,
                                    color: _qty > 1 ? null : muted,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Text(
                                    '$_qty',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => setState(() => _qty++),
                                  child: const Icon(GhIcons.plus, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _addToCart,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.text,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.control,
                                ),
                              ),
                            ),
                            child: Text(
                              'Add · ${rupees(_lineTotal)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    final notifier = ref.read(cartControllerProvider.notifier);
    for (var i = 0; i < _qty; i++) {
      notifier.add(widget.merchant, widget.item);
    }
    Navigator.of(context).pop(true);
  }
}

class _SectionHead extends StatelessWidget {
  const new({required this.title, required this.tag, this.tagColor});

  final String title;
  final String tag;
  final Color? tagColor;

  @override
  Widget build(BuildContext context) {
    final color = tagColor ?? AppColors.textMuted;
    final bg = tagColor == null
        ? AppColors.line
        : tagColor!.withValues(alpha: 0.13);
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(
              tag,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionBox extends StatelessWidget {
  const new({
    required this.surface,
    required this.line,
    required this.children,
  });

  final Color surface;
  final Color line;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(children: children),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
    required this.line,
    required this.muted,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int price;
  final bool selected;
  final VoidCallback onTap;
  final Color line;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15)),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            Text(
              rupees(price < 0 ? 0 : price),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            _RadioDot(on: selected, line: line),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    required this.line,
    required this.muted,
  });

  final IconData icon;
  final String title;
  final int price;
  final bool selected;
  final VoidCallback onTap;
  final Color line;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15)),
            ),
            Text(
              '+${rupees(price)}',
              style: TextStyle(fontSize: 13, color: muted),
            ),
            const SizedBox(width: 10),
            _CheckBox(on: selected, line: line),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const new({required this.on, required this.line});

  final bool on;
  final Color line;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: on ? AppColors.primary : line,
          width: on ? 6 : 1.5,
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const new({required this.on, required this.line});

  final bool on;
  final Color line;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: on ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: on ? AppColors.primary : line, width: 1.5),
      ),
      child: on
          ? const Icon(GhIcons.check, size: 12, color: AppColors.text)
          : null,
    );
  }
}
