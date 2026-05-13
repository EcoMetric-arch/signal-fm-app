import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BtcStrip  (Phase 3)
//
// Changes from Phase 2:
//   • AnimatedSwitcher on the delta chip so changing session animates the value.
//   • Slightly reduced vertical padding for a tighter mobile layout.
//   • Delta background is a faint tinted pill, not a flat box.
// ─────────────────────────────────────────────────────────────────────────────

class BtcStrip extends StatelessWidget {
  const BtcStrip({required this.mode, super.key});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final Color deltaColor = mode.isNegativeDelta
        ? const Color(0xFFFF5252)
        : const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: mode.surfaceColor,
        border: Border.all(color: mode.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: mode.accentGlow,
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── BTC avatar ───────────────────────────────────────────────
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7931A).withOpacity(0.15),
              border: Border.all(
                color: const Color(0xFFF7931A).withOpacity(0.40),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                '₿',
                style: TextStyle(
                  color: Color(0xFFF7931A),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Price ────────────────────────────────────────────────────
          Text(
            'BTC  \$67,892',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: mode.onBackground,
              letterSpacing: 0.2,
            ),
          ),

          const Spacer(),

          // ── Delta chip — AnimatedSwitcher for session change ──────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 340),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: _DeltaChip(
              key: ValueKey(mode.id),
              delta: mode.btcDelta,
              color: deltaColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.delta, required this.color, super.key});

  final String delta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30), width: 1),
      ),
      child: Text(
        delta,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}