import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BtcStrip  (Phase 6)
//
// Matches reference row 2:
//   [₿ icon] [$67,892] [-0.35%] [mini squiggle] ... [58 Neutral] ← F&G mini
//
// The Fear & Greed mini circle is rendered INSIDE this strip on the right,
// matching the reference layout where it sits inline with the BTC row.
// ─────────────────────────────────────────────────────────────────────────────

class BtcStrip extends StatelessWidget {
  const BtcStrip({
    required this.mode,
    super.key,
  });

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final Color deltaColor = mode.isNegativeDelta
        ? const Color(0xFFEF4444)
        : const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mode.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mode.surfaceBorder, width: 1),
      ),
      child: Row(
        children: [
          // ── BTC icon ───────────────────────────────────────────────────
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7931A).withOpacity(0.18),
            ),
            child: const Center(
              child: Text(
                '₿',
                style: TextStyle(
                  color: Color(0xFFF7931A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Price ──────────────────────────────────────────────────────
          Text(
            '\$67,892',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: mode.onBackground,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),

          // ── Delta ──────────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 340),
            child: Text(
              mode.btcDelta,
              key: ValueKey(mode.id),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: deltaColor,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Mini squiggle chart ────────────────────────────────────────
          SizedBox(
            width: 48,
            height: 22,
            child: CustomPaint(
              painter: _MiniChartPainter(
                color: deltaColor,
                isNegative: mode.isNegativeDelta,
              ),
            ),
          ),

          const Spacer(),

          // ── Fear & Greed mini inline ───────────────────────────────────
          _FearGreedMini(mode: mode),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MiniChartPainter — simple 8-point squiggle line
// ─────────────────────────────────────────────────────────────────────────────

class _MiniChartPainter extends CustomPainter {
  _MiniChartPainter({required this.color, required this.isNegative});

  final Color color;
  final bool isNegative;

  static const _upPoints = [0.6, 0.5, 0.7, 0.4, 0.6, 0.3, 0.5, 0.25];
  static const _downPoints = [0.3, 0.4, 0.25, 0.5, 0.35, 0.6, 0.45, 0.7];

  @override
  void paint(Canvas canvas, Size size) {
    final pts = isNegative ? _downPoints : _upPoints;
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = (i / (pts.length - 1)) * size.width;
      final y = pts[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = ((i - 1) / (pts.length - 1)) * size.width;
        final prevY = pts[i - 1] * size.height;
        path.cubicTo(
          prevX + (x - prevX) * 0.5, prevY,
          prevX + (x - prevX) * 0.5, y,
          x, y,
        );
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MiniChartPainter old) =>
      old.isNegative != isNegative || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _FearGreedMini — inline circular indicator matching reference item 3
// ─────────────────────────────────────────────────────────────────────────────

class _FearGreedMini extends StatelessWidget {
  const _FearGreedMini({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final int score = int.tryParse(mode.analytics.fearGreedMini) ?? 50;
    // Color: ≤30 red, 31–50 amber, 51–70 neutral/blue, >70 green
    final Color scoreColor = score <= 30
        ? const Color(0xFFEF4444)
        : score <= 50
            ? const Color(0xFFF59E0B)
            : score <= 70
                ? mode.primaryColor
                : const Color(0xFF22C55E);

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: mode.surfaceColor,
        border: Border.all(color: scoreColor.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: Text(
              mode.analytics.fearGreedMini,
              key: ValueKey(mode.id),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: scoreColor,
                height: 1.0,
              ),
            ),
          ),
          Text(
            mode.analytics.fearGreedLabel,
            style: TextStyle(
              fontSize: 7,
              color: mode.onBackgroundMuted,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
