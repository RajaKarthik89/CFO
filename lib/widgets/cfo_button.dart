import 'package:flutter/material.dart';
import '../app/theme.dart';

enum CFOButtonVariant { primary, secondary, ghost }

enum CFOButtonSize { small, medium, large }

class CFOButton extends StatelessWidget {
  const CFOButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = CFOButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.size = CFOButtonSize.medium,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CFOButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final CFOButtonSize size;

  bool get _disabled => onPressed == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    final double height;
    final EdgeInsets padding;

    switch (size) {
      case CFOButtonSize.small:
        height = 36;
        padding = const EdgeInsets.symmetric(horizontal: 14);
        break;
      case CFOButtonSize.medium:
        height = 46;
        padding = const EdgeInsets.symmetric(horizontal: 20);
        break;
      case CFOButtonSize.large:
        height = 54;
        padding = const EdgeInsets.symmetric(horizontal: 28);
        break;
    }

    final textStyle = context.uiButton;
    final borderRadius = BorderRadius.circular(6);

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: variant == CFOButtonVariant.primary ? cfo.canvas : cfo.brassGold,
        ),
      );
    } else {
      final labelWidget = Text(label, style: textStyle.copyWith(
        color: variant == CFOButtonVariant.primary ? cfo.canvas : cfo.brassGold,
      ));
      child = icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: variant == CFOButtonVariant.primary ? cfo.canvas : cfo.brassGold),
                const SizedBox(width: 8),
                labelWidget,
              ],
            )
          : labelWidget;
    }

    final Widget button;

    switch (variant) {
      case CFOButtonVariant.primary:
        button = ElevatedButton(
          onPressed: _disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: cfo.brassGold,
            disabledBackgroundColor: cfo.brassGold.withValues(alpha: 0.4),
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
          ),
          child: child,
        );
        break;

      case CFOButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: _disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: cfo.brassGold,
            backgroundColor: cfo.cardSurface,
            side: BorderSide(
              color: _disabled ? cfo.brassGold.withValues(alpha: 0.3) : cfo.brassGold,
              width: 1.0,
            ),
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          child: child,
        );
        break;

      case CFOButtonVariant.ghost:
        button = TextButton(
          onPressed: _disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: cfo.brassGold,
            minimumSize: Size(fullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
          ),
          child: child,
        );
        break;
    }

    return button;
  }
}
