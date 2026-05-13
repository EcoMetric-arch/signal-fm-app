import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';
import 'signal_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SignalHeader  (Phase 3)
//
// Changes from Phase 2:
//   • "SIGNAL FM" text replaced with SignalLogo widget (wave icon + logotype).
//   • [compact] forwarded to SignalLogo — hides tagline on mobile.
//   • Adaptive mode badge now pulses via AnimatedOpacity (subtle breath).
// ─────────────────────────────────────────────────────────────────────────────

class SignalHeader extends StatelessWidget {
  const SignalHeader({
    required this.mode,
    this.compact = false,
    super.key,
  });

  final SessionMode mode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Logo ─────────────────────────────────────────────────────────
        SignalLogo(mode: mode, compact: compact),

        // ── Adaptive mode badge ───────────────────────────────────────────
        _AdaptiveBadge(mode: mode),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AdaptiveBadge — pulsing "Adaptive Mode ON" pill
// ─────────────────────────────────────────────────────────────────────────────

class _AdaptiveBadge extends StatefulWidget {
  const _AdaptiveBadge({required this.mode});
  final SessionMode mode;

  @override
  State<_AdaptiveBadge> createState() => _AdaptiveBadgeState();
}

class _AdaptiveBadgeState extends State<_AdaptiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: mode.primaryColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: mode.primaryColor.withOpacity(0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing dot
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: mode.primaryColor.withOpacity(_pulse.value),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mode.primaryColor.withOpacity(_pulse.value * 0.5),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'Adaptive',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: mode.onBackground,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}