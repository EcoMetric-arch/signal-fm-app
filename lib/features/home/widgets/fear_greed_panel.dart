import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FearGreedPanel  (Phase 3)
//
// Changes: AnimatedContainer on card, AnimatedSwitcher on score + mood.
// ─────────────────────────────────────────────────────────────────────────────

class FearGreedPanel extends StatelessWidget {
  const FearGreedPanel({required this.mode, super.key});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: mode.surfaceColor,
        border: Border.all(color: mode.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: mode.accentGlow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Label ──────────────────────────────────────────────────────
          Text(
            'Fear & Greed',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: mode.onBackgroundMuted,
            ),
          ),

          const SizedBox(height: 8),

          // ── Score — fades/slides on session change ─────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              mode.fearIndex,
              key: ValueKey(mode.id),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: mode.primaryColor,
                height: 1.0,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Mood chip ──────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Container(
              key: ValueKey('${mode.id}_mood'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: mode.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: mode.primaryColor.withOpacity(0.28),
                  width: 1,
                ),
              ),
              child: Text(
                mode.mood,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: mode.primaryColor,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}