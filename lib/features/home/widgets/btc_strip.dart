import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BtcStrip — BTC price row with inline Fear & Greed mini
// Dart compatibility: Dart 2.17+, no records, no abstract final class.
// ─────────────────────────────────────────────────────────────────────────────

class BtcStrip extends StatelessWidget {
  const BtcStrip({required this.mode, super.key});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final Color deltaColor = mode.isNegativeDelta
        ? const Color(0xFFFF4D6A)
        : const Color(0xFF23D96A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.13), width: 1),
      ),
      child: Row(
        children: <Widget>[
          // ── BTC avatar ─────────────────────────────────────────────────
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF7931A).withOpacity(0.16),
            ),
            child: const Center(
              child: Text(
                '₿',
                style: TextStyle(
                  color: Color(0xFFF7931A),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Price ──────────────────────────────────────────────────────
          const Text(
            '\$67,892',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF5F6FA),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 7),

          // ── Delta ──────────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              mode.btcDelta,
              key: ValueKey<String>(mode.id),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: deltaColor,
              ),
            ),
          ),
          const SizedBox(width: 7),

          // ── Mini squiggle chart ────────────────────────────────────────
          SizedBox(
            width: 46,
            height: 20,
            child: CustomPaint(
              painter: _MiniChartPainter(
                color: deltaColor,
                negative: mode.isNegativeDelta,
              ),
            ),
          ),

          const Spacer(),

          // ── Fear & Greed mini ──────────────────────────────────────────
          _FgMini(mode: mode),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MiniChartPainter
// ─────────────────────────────────────────────────────────────────────────────

class _MiniChartPainter extends CustomPainter {
  _MiniChartPainter({required this.color, required this.negative});

  final Color color;
  final bool negative;

  static const List<double> _up = <double>[
    0.60, 0.48, 0.68, 0.38, 0.58, 0.30, 0.50, 0.24,
  ];
  static const List<double> _dn = <double>[
    0.32, 0.42, 0.26, 0.50, 0.36, 0.60, 0.46, 0.70,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final List<double> pts = negative ? _dn : _up;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();
    for (int i = 0; i < pts.length; i++) {
      final double x = (i / (pts.length - 1)) * size.width;
      final double y = pts[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final double px = ((i - 1) / (pts.length - 1)) * size.width;
        final double py = pts[i - 1] * size.height;
        path.cubicTo(
          px + (x - px) * 0.5, py,
          px + (x - px) * 0.5, y,
          x, y,
        );
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MiniChartPainter old) {
    return old.negative != negative || old.color != color;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FgMini — inline Fear & Greed circle
// ─────────────────────────────────────────────────────────────────────────────

class _FgMini extends StatelessWidget {
  const _FgMini({required this.mode});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final int score =
        int.tryParse(mode.analytics.fearGreedMini) ?? 50;
    final Color c = _scoreColor(score, mode.primaryColor);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: c.withOpacity(0.45), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            child: Text(
              mode.analytics.fearGreedMini,
              key: ValueKey<String>(mode.id),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: c,
                height: 1.0,
              ),
            ),
          ),
          Text(
            mode.analytics.fearGreedLabel,
            style: const TextStyle(
              fontSize: 7,
              color: Color(0xFF6B82A0),
            ),
          ),
        ],
      ),
    );
  }

  static Color _scoreColor(int score, Color primary) {
    if (score <= 30) return const Color(0xFFFF4D6A);
    if (score <= 50) return const Color(0xFFF59E0B);
    if (score <= 70) return primary;
    return const Color(0xFF23D96A);
  }
}
