import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Reusable premium card system matching the "Ledger & Ember" design system.
class CFOCard extends StatelessWidget {
  const CFOCard({
    super.key,
    this.child,
    this.header,
    this.headerIcon,
    this.headerTrailing,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.borderRadius = 16,
    this.backgroundColor,
    this.elevation,
    this.showBorder = false,
  });

  final Widget? child;
  final String? header;
  final IconData? headerIcon;
  final Widget? headerTrailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final double? elevation;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final cfoColors = context.cfoColors;
    final radius = BorderRadius.circular(borderRadius);
    final bg = backgroundColor ?? cfoColors.cardSurface;

    Widget card = Material(
      color: bg,
      borderRadius: radius,
      elevation: elevation ?? 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: cfoColors.brassGold.withValues(alpha: 0.08),
        highlightColor: cfoColors.brassGold.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: const Color(0xFF1B2036),
              width: 0.5,
            ),
          ),
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) ...[
                Row(
                  children: [
                    if (headerIcon != null) ...[
                      Icon(headerIcon, size: 16, color: cfoColors.brassGold),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        header!.toUpperCase(),
                        style: context.uiLabel.copyWith(
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (headerTrailing != null) headerTrailing!,
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
