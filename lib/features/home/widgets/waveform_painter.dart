import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WaveformDisplay  (Phase 3 upgrade)
//
// Changes from Phase 2:
//   • Accepts [waveformColors] — a 3-stop per-session color list.
//   • Draws mirrored bars (above + below centre line) for a richer look.
//   • Adds a soft glow pass under the bars using a wider, transparent rect.
//   • Playhead window: bars ±4 positions from the current head are
//     highlighted at full opacity; the rest fade smoothly.
//   • Animation speed is slightly faster (1 200 ms) for a more live feel.
//
// No external packages. Pure CustomPainter + AnimationController.
// ─────────────────────────────────────────────────────────────────────────────

class WaveformDisplay extends StatefulWidget {
  const WaveformDisplay({
    required this.accentColor,
    required this.waveformColors,
    super.key,
  });

  final Color accentColor;

  /// 3-stop color list from SessionMode.waveformColors.
  /// [0] = base, [1] = mid, [2] = peak.
  final List<Color> waveformColors;

  @override
  State<WaveformDisplay> createState() => _WaveformDisplayState();
}

class _WaveformDisplayState extends State<WaveformDisplay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _WaveformPainter(
          waveformColors: widget.waveformColors,
          animValue: _ctrl.value,
        ),
        size: const Size(double.infinity, 64),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WaveformPainter
// ─────────────────────────────────────────────────────────────────────────────

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.waveformColors,
    required this.animValue,
  });

  final List<Color> waveformColors;
  final double animValue;

  // 48 bars — enough density without being too small on mobile
  static const int _kCount = 48;
  static const double _kGap = 2.5;
  static const double _kMinRatio = 0.08;

  // Pre-baked bar height ratios — realistic waveform shape
  static const List<double> _kRatios = [
    0.22, 0.38, 0.50, 0.34, 0.66, 0.48, 0.74, 0.42,
    0.86, 0.60, 0.72, 0.45, 0.82, 0.68, 0.92, 0.55,
    0.78, 0.40, 0.64, 0.50, 0.88, 0.36, 0.70, 0.58,
    0.94, 0.62, 0.80, 0.44, 0.72, 0.30, 0.52, 0.24,
    0.46, 0.34, 0.58, 0.40, 0.66, 0.32, 0.54, 0.28,
    0.42, 0.36, 0.50, 0.44, 0.62, 0.38, 0.56, 0.30,
  ];

  // Resolve a bar color by interpolating across the 3-stop waveformColors list.
  Color _barColor(double ratio, double opacity) {
    final c0 = waveformColors[0];
    final c1 = waveformColors[1];
    final c2 = waveformColors[2];

    final Color c = ratio < 0.5
        ? Color.lerp(c0, c1, ratio / 0.5)!
        : Color.lerp(c1, c2, (ratio - 0.5) / 0.5)!;

    return c.withOpacity(opacity);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double barW = (size.width - _kGap * (_kCount - 1)) / _kCount;
    final double halfH = size.height / 2;
    // Tallest bar can reach 90 % of half-height in each direction
    final double maxHalf = halfH * 0.90;

    // Playhead advances linearly across bars
    final int head = (animValue * _kCount).floor() % _kCount;
    const int highlight = 5; // bars on each side of head at full opacity

    for (int i = 0; i < _kCount; i++) {
      final double x = i * (barW + _kGap);

      // Breathing offset — each bar oscillates independently
      final double breathe =
          math.sin(animValue * 2 * math.pi + i * 0.42) * 0.07;
      final double ratio = (_kRatios[i] + breathe).clamp(_kMinRatio, 1.0);

      // Distance-based opacity
      final int dist = (i - head).abs();
      final double opacity = dist <= highlight
          ? 1.0 - (dist / (highlight + 1)) * 0.35
          : 0.22 + 0.20 * ratio; // dim but still visible

      final double halfBar = math.max(2.0, ratio * maxHalf);

      // ── Glow pass (wide, very transparent) ──────────────────────────
      if (dist <= highlight + 2) {
        final glowPaint = Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
          ..color = _barColor(ratio, opacity * 0.18);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 1, halfH - halfBar - 1, barW + 2, halfBar * 2 + 2),
            const Radius.circular(4),
          ),
          glowPaint,
        );
      }

      // ── Upper bar (above centre) ─────────────────────────────────────
      final barPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = _barColor(ratio, opacity);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, halfH - halfBar, barW, halfBar),
          const Radius.circular(2),
        ),
        barPaint,
      );

      // ── Lower bar (mirror, 60 % height for asymmetry) ────────────────
      final double lowerH = halfBar * 0.60;
      barPaint.color = _barColor(ratio, opacity * 0.55);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, halfH, barW, lowerH),
          const Radius.circular(2),
        ),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.animValue != animValue ||
      old.waveformColors[0] != waveformColors[0];
}