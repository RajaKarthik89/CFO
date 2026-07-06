import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';
import '../../widgets/cfo_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onContinue() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final cfo = context.cfoColors;

    return Scaffold(
      backgroundColor: cfo.canvas,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // ── Logo Mark ──────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: cfo.cardSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cfo.brassGold.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 28,
                      color: cfo.brassGold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Title ─────────────────────────
                  Text(
                    'CFO',
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: cfo.warmWhite,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Subtitle (Fraunces) ───────────
                  Text(
                    'Your AI Financial Operating System',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fraunces(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: cfo.warmWhite,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Subtext ───────────────────────
                  Text(
                    'An intelligent platform that actually understands your financial data, instead of just displaying it.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: cfo.mutedSlate,
                      height: 1.6,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── CTA Button ────────────────────
                  CFOButton(
                    label: 'Continue as Karthik (Demo)',
                    onPressed: _onContinue,
                    icon: Icons.arrow_forward_rounded,
                    fullWidth: true,
                    size: CFOButtonSize.large,
                  ),

                  const SizedBox(height: 16),

                  // ── Footnote ──────────────────────
                  Text(
                    'Local mock database mode • No sign-up required',
                    style: context.uiLabel.copyWith(
                      fontSize: 11,
                      color: cfo.mutedSlate.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
