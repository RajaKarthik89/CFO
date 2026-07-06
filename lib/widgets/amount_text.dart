import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';

enum AmountType {
  credit,   // money-positive (Gold)
  debit,    // standard outflow (Warm White)
  warning,  // warning/danger (Rust)
  neutral,  // secondary text (Slate)
}

enum AmountSize {
  small,
  medium,
  large,
  hero,
}

/// Formatted currency display for Indian Rupees (₹) using IBM Plex Mono.
class AmountText extends StatelessWidget {
  const AmountText(
    this.amount, {
    super.key,
    this.type = AmountType.debit,
    this.size = AmountSize.medium,
    this.showSign = false,
    this.colorOverride,
    this.prefix,
  });

  final double amount;
  final AmountType type;
  final AmountSize size;
  final bool showSign;
  final Color? colorOverride;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    // ── Color ───────────────────────────────
    final Color color;
    if (colorOverride != null) {
      color = colorOverride!;
    } else {
      switch (type) {
        case AmountType.credit:
          color = cfo.brassGold;
        case AmountType.debit:
          color = cfo.warmWhite;
        case AmountType.warning:
          color = cfo.warningRust;
        case AmountType.neutral:
          color = cfo.mutedSlate;
      }
    }

    // ── Font Size ───────────────────────────
    final double fontSize;
    final FontWeight fontWeight;
    switch (size) {
      case AmountSize.small:
        fontSize = 13;
        fontWeight = FontWeight.w500;
        break;
      case AmountSize.medium:
        fontSize = 17;
        fontWeight = FontWeight.w600;
        break;
      case AmountSize.large:
        fontSize = 26;
        fontWeight = FontWeight.w700;
        break;
      case AmountSize.hero:
        fontSize = 36;
        fontWeight = FontWeight.w700;
        break;
    }

    // ── Formatting ──────────────────────────
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );
    final formatted = formatter.format(amount.abs());

    String sign = '';
    if (showSign) {
      sign = amount > 0 ? '+' : (amount < 0 ? '-' : '');
    }

    final displayText = '${prefix ?? ''}$sign$formatted';

    return Text(
      displayText,
      style: GoogleFonts.ibmPlexMono(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
