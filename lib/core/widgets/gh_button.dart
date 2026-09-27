import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Primary action. Press scales to 0.97 instead of flashing.
class GhButton extends StatefulWidget {
  /// Creates a button. A null [onPressed] disables it.
  const new({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    super.key,
  });

  /// Button copy.
  final String label;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Quiet surface style for secondary actions.
  final bool secondary;

  @override
  State<GhButton> createState() => _GhButtonState();
}

class _GhButtonState extends State<GhButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = _fill(dark);
    final foreground = widget.secondary
        ? (dark ? AppColors.darkText : AppColors.text)
        : (dark ? AppColors.darkBackground : AppColors.surface);
    return GestureDetector(
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: _opacity(enabled),
          duration: const Duration(milliseconds: 120),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: widget.secondary ? Border.all(color: _line(dark)) : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool pressed) => setState(() => _pressed = pressed);

  Color _fill(bool dark) {
    if (widget.secondary) {
      return dark ? AppColors.darkSurface : AppColors.surface;
    }
    return dark ? AppColors.darkPrimary : AppColors.primary;
  }

  Color _line(bool dark) => dark ? AppColors.darkLine : AppColors.line;

  double _opacity(bool enabled) {
    if (!enabled) return 0.4;
    if (_pressed) return 0.9;
    return 1;
  }
}
