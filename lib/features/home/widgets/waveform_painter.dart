import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WaveformDisplay  (Phase 5)
//
// New: accepts [marketState] which modifies:
//   • animSpeedScale → AnimationController duration (faster = more energy)
//   • peakScale      → maximum bar height multiplier
//   • breatheScale   → idle oscillation amplitude
//   • glowScale      → glow pass opacity
//
// Session character table:
//   London Open   → warm, medium breathing, smooth peaks
//   NY Momentum   → fast, high peaks, electric glow
//   Tokyo Night   → slow, low peaks, gentle drift
//   Deep Focus    → minimal motion, ultra-fine peaks, precise
//   Recovery Mode → very slow, soft rounded bars, dim glow
//
// Market state then layers on top:
//   Panic / Breakout → faster, sharper, brighter
//   Calm / Risk-Off  → slower, shorter, dimmer
//   Recovery         → softest possible motion
// ─────────────────────────────────────────────────────────────────────────────

class WaveformDisplay extends StatefulWidget {
  const WaveformDisplay({
    required this.accentColor,
    required this.waveformColors,
    required this.marketState,
    super.key,
  });

  final Color accentColor;
  final List<Color> waveformColors;
  final MarketStateData marketState;

  @override
  State<WaveformDisplay> createState() => _WaveformDisplayState();
}

class _WaveformDisplayState extends State<WaveformDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // Base duration: 1400 ms. Divided by animSpeedScale.
  static const int _kBaseDurationMs = 1400;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: _duration(),
    )..repeat();
  }

  @override
  void didUpdateWidget(WaveformDisplay old) {
    super.didUpdateWidget(old);
    // If speed scale changed, smoothly adjust duration
    if (old.marketState.animSpeedScale != widget.marketState.animSpeedScale) {
      _ctrl.duration = _duration();
      if (!_ctrl.isAnimating) _ctrl.repeat();
    }
  }

  Duration _duration() => Duration(
        milliseconds:
            (_kBaseDurationMs / widget.marketState.animSpeedScale).round(),
      );

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
          peakScale: widget.marketState.peakScale,
          breatheScale: widget.marketState.breatheScale,
          glowScale: widget.marketState.glowScale,
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
    required this.peakScale,
    required this.breatheScale,
    required this.glowScale,
  });

  final List<Color> waveformColors;
  final double animValue;
  final double peakScale;
  final double breatheScale;
  final double glowScale;

  static const int _kCount = 48;
  static const double _kGap = 2.5;
  static const double _kMinRatio = 0.06;

  static const List<double> _kRatios = [
    0.22, 0.38, 0.50, 0.34, 0.66, 0.48, 0.74, 0.42,
    0.86, 0.60, 0.72, 0.45, 0.82, 0.68, 0.92, 0.55,
    0.78, 0.40, 0.64, 0.50, 0.88, 0.36, 0.70, 0.58,
    0.94, 0.62, 0.80, 0.44, 0.72, 0.30, 0.52, 0.24,
    0.46, 0.34, 0.58, 0.40, 0.66, 0.32, 0.54, 0.28,
    0.42, 0.36, 0.50, 0.44, 0.62, 0.38, 0.56, 0.30,
  ];

  Color _barColor(double ratio, double opacity) {
    final c0 = waveformColors[0];
    final c1 = waveformColors[1];
    final c2 = waveformColors[2];
    final Color c = ratio < 0.5
        ? Color.lerp(c0, c1, ratio / 0.5)!
        : Color.lerp(c1, c2, (ratio - 0.5) / 0.5)!;
    return c.withOpacity(opacity.clamp(0.0, 1.0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double barW = (size.width - _kGap * (_kCount - 1)) / _kCount;
    final double halfH = size.height / 2;
    // peakScale modifies the maximum reach — panic = taller, calm = shorter
    final double maxHalf = halfH * 0.90 * peakScale.clamp(0.4, 1.4);

    final int head = (animValue * _kCount).floor() % _kCount;
    const int highlight = 5;

    for (int i = 0; i < _kCount; i++) {
      final double x = i * (barW + _kGap);

      // breatheScale controls idle oscillation amplitude
      final double breatheAmp = 0.07 * breatheScale.clamp(0.3, 1.5);
      final double breathe =
          math.sin(animValue * 2 * math.pi + i * 0.42) * breatheAmp;

      final double ratio = (_kRatios[i] + breathe).clamp(_kMinRatio, 1.0);

      final int dist = (i - head).abs();
      final double opacity = dist <= highlight
          ? (1.0 - (dist / (highlight + 1)) * 0.30).clamp(0.0, 1.0)
          : (0.20 + 0.18 * ratio).clamp(0.0, 1.0);

      final double halfBar = math.max(1.5, ratio * maxHalf);

      // ── Glow pass ────────────────────────────────────────────────────
      if (dist <= highlight + 2 && glowScale > 0.3) {
        final glowOpacity = (opacity * 0.18 * glowScale).clamp(0.0, 0.55);
        final glowPaint = Paint()
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            (3.5 * glowScale).clamp(1.0, 8.0),
          )
          ..color = _barColor(ratio, glowOpacity);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
                x - 1, halfH - halfBar - 1, barW + 2, halfBar * 2 + 2),
            const Radius.circular(4),
          ),
          glowPaint,
        );
      }

      // ── Upper bar ────────────────────────────────────────────────────
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

      // ── Lower mirror (60 % — asymmetric) ─────────────────────────────
      final double lowerH = halfBar * 0.60;
      barPaint.color = _barColor(ratio, opacity * 0.50);
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
      old.peakScale != peakScale ||
      old.breatheScale != breatheScale ||
      old.glowScale != glowScale ||
      old.waveformColors[0] != waveformColors[0];
}
