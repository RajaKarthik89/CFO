import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../app/theme.dart';

/// Reusable banner for AI-generated insights, styled with Fraunces.
class InsightBanner extends StatefulWidget {
  const InsightBanner({
    super.key,
    required this.text,
    this.isLoading = false,
    this.icon = Icons.auto_awesome_rounded,
    this.accentColor,
    this.isItalic = false,
  });

  final String text;
  final bool isLoading;
  final IconData icon;
  final Color? accentColor;
  final bool isItalic;

  @override
  State<InsightBanner> createState() => _InsightBannerState();
}

class _InsightBannerState extends State<InsightBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    if (!widget.isLoading && widget.text.isNotEmpty) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant InsightBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading && widget.text.isNotEmpty) {
      _fadeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;
    final accent = widget.accentColor ?? cfo.brassGold;

    return Container(
      decoration: BoxDecoration(
        color: cfo.cardSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cfo.mutedSlate.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Accent bar ──────────────────────
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),

            // ── Content ─────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: widget.isLoading
                    ? _buildShimmer(context)
                    : _buildContent(context, accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accent) {
    final textStyle = widget.isItalic ? context.aiQuoteItalic : context.aiBody;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(widget.icon, size: 16, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.text,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final cfo = context.cfoColors;
    return Shimmer.fromColors(
      baseColor: cfo.cardSurface,
      highlightColor: cfo.mutedSlate.withValues(alpha: 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBar(width: double.infinity, height: 10),
          const SizedBox(height: 8),
          _shimmerBar(width: double.infinity, height: 10),
          const SizedBox(height: 8),
          _shimmerBar(width: 150, height: 10),
        ],
      ),
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
