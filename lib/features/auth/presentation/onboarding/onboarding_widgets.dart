import 'package:attock_xpress/core/theme/app_colors.dart';
import 'package:attock_xpress/core/widgets/brand_mark.dart';
import 'package:attock_xpress/core/widgets/gh_button.dart';
import 'package:flutter/material.dart';

/// Shared chrome for every onboarding step.
class OnboardingScaffold extends StatelessWidget {
  /// Creates the scaffold.
  const new({
    required this.children,
    this.mark,
    this.onBack,
    this.onSkip,
    super.key,
  });

  /// Body widgets in a scrollable column.
  final List<Widget> children;

  /// Optional customer/rider mark at the top.
  final BrandMarkKind? mark;

  /// Optional back action.
  final VoidCallback? onBack;

  /// Skip straight into a preview home.
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: onBack, onSkip: onSkip),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                children: [
                  if (mark != null) ...[
                    BrandMark(kind: mark!, size: 44),
                    const SizedBox(height: 16),
                  ],
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const new({this.onBack, this.onSkip});

  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              child: const Text('Skip for now'),
            ),
        ],
      ),
    );
  }
}

/// Primary + optional secondary / text actions stacked at the bottom.
class OnboardingActions extends StatelessWidget {
  /// Creates the action stack.
  const new({
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.textLabel,
    this.onText,
    super.key,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? textLabel;
  final VoidCallback? onText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GhButton(label: primaryLabel, onPressed: onPrimary),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 10),
          GhButton(
            label: secondaryLabel!,
            secondary: true,
            onPressed: onSecondary,
          ),
        ],
        if (textLabel != null && onText != null) ...[
          const SizedBox(height: 4),
          TextButton(
            onPressed: onText,
            child: Text(
              textLabel!,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }
}

/// Bordered field used on onboarding forms.
class OnboardingField extends StatelessWidget {
  /// Creates a text field shell.
  const new({
    required this.controller,
    required this.hint,
    this.label,
    this.prefix,
    this.keyboardType,
    this.obscure = false,
    this.focused = false,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final String? label;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: dark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focused
                  ? AppColors.primary
                  : (dark ? AppColors.darkLine : AppColors.line),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (prefix != null) ...[
                  prefix!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Six boxes that mirror a single [controller].
class OtpBoxes extends StatelessWidget {
  /// Creates the OTP row.
  const new({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: const TextStyle(
        letterSpacing: 18,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '------',
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// Selectable chip row.
class ChoiceChips extends StatelessWidget {
  /// Creates chips.
  const new({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _Chip(
            label: option,
            selected: option == selected,
            onTap: () => onSelect(option),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? (dark ? AppColors.darkPeach : AppColors.tint)
          : (dark ? AppColors.darkSurface : AppColors.surface),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (dark ? AppColors.darkLine : AppColors.line),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : null,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Large tappable tile with mark or icon.
class OnboardingTile extends StatelessWidget {
  /// Creates a tile.
  const new({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.leading,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? (dark ? AppColors.darkPeach : AppColors.tint)
          : (dark ? AppColors.darkSurface : AppColors.surface),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (dark ? AppColors.darkLine : AppColors.line),
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
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
