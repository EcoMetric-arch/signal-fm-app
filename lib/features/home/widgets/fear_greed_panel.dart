import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FearGreedPanel  (Phase 6)
//
// The Fear & Greed score is now shown INLINE inside BtcStrip (right side).
// This standalone panel is kept for any layout that needs a larger version,
// but is not used in the main mobile single-column flow.
// ─────────────────────────────────────────────────────────────────────────────

class FearGreedPanel extends StatelessWidget {
  const FearGreedPanel({required this.mode, super.key});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final int score = int.tryParse(mode.analytics.fearGreedMini) ?? 50;
    final Color scoreColor = score <= 30
        ? const Color(0xFFEF4444)
        : score <= 50
            ? const Color(0xFFF59E0B)
            : score <= 70
                ? mode.primaryColor
                : const Color(0xFF22C55E);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'FEAR & GREED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: mode.onBackgroundMuted,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _LargeGaugePainter(score: score, color: scoreColor),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      child: Text(
                        mode.fearIndex,
                        key: ValueKey(mode.id),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                          height: 1.0,
                        ),
                      ),
                    ),
                    Text(
                      mode.analytics.fearGreedLabel,
                      style: TextStyle(
                        fontSize: 9,
                        color: mode.onBackgroundMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LargeGaugePainter extends CustomPainter {
  _LargeGaugePainter({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepTotal, false,
      Paint()
        ..color = color.withOpacity(0.15)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepTotal * (score / 100), false,
      Paint()
        ..color = color
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LargeGaugePainter old) =>
      old.score != score || old.color != color;
}
