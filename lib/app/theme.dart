import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// CFO "LEDGER & EMBER" THEME SYSTEM
// ─────────────────────────────────────────────

/// Custom extension for semantic and specific brand colors.
/// Access using `context.cfoColors`.
@immutable
class CFOColors extends ThemeExtension<CFOColors> {
  const CFOColors({
    required this.canvas,
    required this.cardSurface,
    required this.warmWhite,
    required this.mutedSlate,
    required this.brassGold,
    required this.warningRust,
    required this.wakingLedgerTop,
  });

  final Color canvas;
  final Color cardSurface;
  final Color warmWhite;
  final Color mutedSlate;
  final Color brassGold;
  final Color warningRust;
  final Color wakingLedgerTop;

  static const dark = CFOColors(
    canvas: Color(0xFF0B0E1A),
    cardSurface: Color(0xFF141A2E),
    warmWhite: Color(0xFFF3F1EA),
    mutedSlate: Color(0xFF8B92A8),
    brassGold: Color(0xFFC9A44C),
    warningRust: Color(0xFFC1554D),
    wakingLedgerTop: Color(0xFF1A1F35),
  );

  static const light = CFOColors(
    canvas: Color(0xFFF3F1EA),
    cardSurface: Color(0xFFE8E5DA),
    warmWhite: Color(0xFF0B0E1A),
    mutedSlate: Color(0xFF5A6075),
    brassGold: Color(0xFF9E7C2B),
    warningRust: Color(0xFFC1554D),
    wakingLedgerTop: Color(0xFFD6D1BF),
  );

  @override
  CFOColors copyWith({
    Color? canvas,
    Color? cardSurface,
    Color? warmWhite,
    Color? mutedSlate,
    Color? brassGold,
    Color? warningRust,
    Color? wakingLedgerTop,
  }) {
    return CFOColors(
      canvas: canvas ?? this.canvas,
      cardSurface: cardSurface ?? this.cardSurface,
      warmWhite: warmWhite ?? this.warmWhite,
      mutedSlate: mutedSlate ?? this.mutedSlate,
      brassGold: brassGold ?? this.brassGold,
      warningRust: warningRust ?? this.warningRust,
      wakingLedgerTop: wakingLedgerTop ?? this.wakingLedgerTop,
    );
  }

  @override
  CFOColors lerp(covariant ThemeExtension<CFOColors>? other, double t) {
    if (other is! CFOColors) return this;
    return CFOColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      warmWhite: Color.lerp(warmWhite, other.warmWhite, t)!,
      mutedSlate: Color.lerp(mutedSlate, other.mutedSlate, t)!,
      brassGold: Color.lerp(brassGold, other.brassGold, t)!,
      warningRust: Color.lerp(warningRust, other.warningRust, t)!,
      wakingLedgerTop: Color.lerp(wakingLedgerTop, other.wakingLedgerTop, t)!,
    );
  }
}

final ThemeData cfoDarkTheme = _buildTheme(Brightness.dark);
final ThemeData cfoLightTheme = _buildTheme(Brightness.light);

ThemeData _buildTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  final colors = isDark ? CFOColors.dark : CFOColors.light;

  final colorScheme = isDark
      ? ColorScheme.dark(
          brightness: Brightness.dark,
          surface: colors.canvas,
          onSurface: colors.warmWhite,
          primary: colors.brassGold,
          onPrimary: colors.canvas,
          secondary: colors.brassGold,
          onSecondary: colors.canvas,
          surfaceContainerHighest: colors.cardSurface,
          error: colors.warningRust,
          onError: colors.warmWhite,
          outline: colors.mutedSlate.withValues(alpha: 0.3),
        )
      : ColorScheme.light(
          brightness: Brightness.light,
          surface: colors.canvas,
          onSurface: colors.warmWhite,
          primary: colors.brassGold,
          onPrimary: colors.canvas,
          secondary: colors.brassGold,
          onSecondary: colors.canvas,
          surfaceContainerHighest: colors.cardSurface,
          error: colors.warningRust,
          onError: colors.warmWhite,
          outline: colors.mutedSlate.withValues(alpha: 0.3),
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.canvas,
    extensions: [colors],
    dividerTheme: DividerThemeData(
      color: colors.mutedSlate.withValues(alpha: 0.2),
      thickness: 0.5,
    ),
    
    // ── AppBar Theme ────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: colors.warmWhite,
        fontWeight: FontWeight.w600,
        fontSize: 19,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: colors.warmWhite),
    ),

    // ── Card Theme ──────────────────────────────
    cardTheme: CardThemeData(
      color: colors.cardSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // ── Bottom Navigation Theme (Icon Only) ──────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.canvas,
      indicatorColor: colors.brassGold.withValues(alpha: 0.15),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // Icon only!
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: colors.brassGold, size: 24);
        }
        return IconThemeData(color: colors.mutedSlate.withValues(alpha: 0.6), size: 24);
      }),
    ),

    // ── Input Decoration Theme ──────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.cardSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.mutedSlate.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.mutedSlate.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colors.brassGold, width: 1.0),
      ),
      hintStyle: GoogleFonts.inter(
        color: colors.mutedSlate.withValues(alpha: 0.6),
        fontSize: 16,
      ),
    ),

    // ── Chip Theme ──────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: colors.cardSurface,
      selectedColor: colors.brassGold.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.inter(
        fontSize: 14, 
        fontWeight: FontWeight.w500,
        color: colors.warmWhite,
      ),
      side: BorderSide(color: colors.mutedSlate.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// CONVENIENCE HELPERS
// ─────────────────────────────────────────────
extension CFOThemeX on BuildContext {
  CFOColors get cfoColors => Theme.of(this).extension<CFOColors>()!;
  
  // ── Monospace (IBM Plex Mono) for Numbers ──
  TextStyle get numberLarge => GoogleFonts.ibmPlexMono(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: cfoColors.warmWhite,
      );

  TextStyle get numberMedium => GoogleFonts.ibmPlexMono(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: cfoColors.warmWhite,
      );

  TextStyle get numberSmall => GoogleFonts.ibmPlexMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: cfoColors.mutedSlate,
      );

  // ── Serif (Fraunces) for AI generated text ──
  TextStyle get aiBody => GoogleFonts.fraunces(
        fontSize: 19,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: cfoColors.warmWhite,
      );

  TextStyle get aiBriefing => GoogleFonts.fraunces(
        fontSize: 26,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: cfoColors.warmWhite,
      );

  TextStyle get aiQuoteItalic => GoogleFonts.fraunces(
        fontSize: 19,
        fontStyle: FontStyle.italic,
        height: 1.6,
        color: cfoColors.warmWhite,
      );

  // ── Sans-serif (Inter) for UI chrome ────────
  TextStyle get uiLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: cfoColors.mutedSlate,
      );

  TextStyle get uiHeader => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: cfoColors.warmWhite,
      );

  TextStyle get uiButton => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: cfoColors.canvas,
      );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
