import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SignalLogo
//
// Adaptive Signal FM branding block used in SignalHeader.
// Contains three parts rendered in a Row:
//   1. _WaveIconPainter  — a small 3-bar wave mark drawn with CustomPainter.
//                          Color follows mode.primaryColor.
//   2. "SIGNAL FM"       — bold logotype in mode.onBackground.
//   3. Tagline column    — "Sound. Markets. You." below the logotype,
//                          in mode.onBackgroundMuted (only when !compact).
//
// [compact] = true is used on mobile to save horizontal space (hides tagline).
// ─────────────────────────────────────────────────────────────────────────────

class SignalLogo extends StatelessWidget {
  const SignalLogo({
    required this.mode,
    this.compact = false,
    super.key,
  });

  final SessionMode mode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Wave mark ────────────────────────────────────────────────────
        SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(
            painter: _WaveIconPainter(color: mode.primaryColor),
          ),
        ),

        const SizedBox(width: 9),

        // ── Logotype + tagline ───────────────────────────────────────────
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIGNAL FM',
              style: TextStyle(
                fontSize: compact ? 20 : 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: mode.onBackground,
                height: 1.0,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 2),
              Text(
                'Sound. Markets. You.',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                  color: mode.onBackgroundMuted,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WaveIconPainter
//
// Draws 3 rounded vertical bars of increasing height — a minimal signal/wave
// mark that echoes both the waveform and a radio signal icon.
// Color is passed in so it follows the session accent.
// ─────────────────────────────────────────────────────────────────────────────

class _WaveIconPainter extends CustomPainter {
  const _WaveIconPainter({required this.color});

  final Color color;

  // Heights as fractions of the widget's total height (0.0–1.0).
  static const _heights = [0.45, 0.72, 1.0, 0.72, 0.45];
  static const _barW = 3.0;
  static const _gap = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final totalW = _heights.length * _barW + (_heights.length - 1) * _gap;
    final startX = (size.width - totalW) / 2;

    for (int i = 0; i < _heights.length; i++) {
      final barH = _heights[i] * size.height;
      final x = startX + i * (_barW + _gap);
      final y = (size.height - barH) / 2;

      // Opacity gradient: outer bars slightly dimmer
      final opacity = 0.55 + 0.45 * math.pow(
        1 - ((i - 2).abs() / 2),
        1.5,
      ).toDouble();
      paint.color = color.withOpacity(opacity);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, _barW, barH),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveIconPainter old) => old.color != color;
}