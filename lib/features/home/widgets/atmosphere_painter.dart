import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AtmosphereLayer — living ambient background
//
// Draws 2 radial orbs that drift slowly on independent sine paths.
// 3-stop RadialGradient with stops [0.0, 0.28, 1.0]:
//   • Tight bright core (0→0.28): clearly visible accent color
//   • Rapid clean falloff (0.28→1.0): no fog accumulation
//
// Dart compatibility: no abstract final class, no records. Dart 2.17+.
// ─────────────────────────────────────────────────────────────────────────────

class AtmosphereLayer extends StatefulWidget {
  const AtmosphereLayer({
    required this.mode,
    required this.marketState,
    super.key,
  });

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  State<AtmosphereLayer> createState() => _AtmosphereLayerState();
}

class _AtmosphereLayerState extends State<AtmosphereLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
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
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _AtmospherePainter(
            colors: widget.mode.atmosphereColors,
            animValue: _ctrl.value,
            speedScale: widget.marketState.animSpeedScale,
            glowScale: widget.marketState.glowScale,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter({
    required this.colors,
    required this.animValue,
    required this.speedScale,
    required this.glowScale,
  });

  final List<Color> colors;
  final double animValue;
  final double speedScale;
  final double glowScale;

  @override
  void paint(Canvas canvas, Size size) {
    // Orb A and B use different phase offsets so they drift independently.
    final double tA = animValue * speedScale;
    final double tB = ((animValue + 0.18) % 1.0) * (speedScale * 0.72);

    final double w = size.width;
    final double h = size.height;
    final double diag = math.sqrt(w * w + h * h);

    // ── Orb A — primary accent, upper-left drift ──────────────────────
    final double axN = 0.25 + 0.14 * math.sin(tA * 2.0 * math.pi * 0.55);
    final double ayN = 0.20 + 0.09 * math.cos(tA * 2.0 * math.pi * 0.42);
    // Base opacity 0.18, hard cap 0.28 — vivid but no fog
    final double aOp = (0.18 * glowScale).clamp(0.0, 0.28);
    _drawOrb(canvas, size, axN, ayN, diag * 0.30, colors[1], aOp);

    // ── Orb B — secondary bloom, lower-right drift ────────────────────
    final double bxN = 0.74 + 0.10 * math.cos(tB * 2.0 * math.pi * 0.50);
    final double byN = 0.72 + 0.12 * math.sin(tB * 2.0 * math.pi * 0.60);
    final double bOp = (0.12 * glowScale).clamp(0.0, 0.20);
    _drawOrb(canvas, size, bxN, byN, diag * 0.22, colors[2], bOp);
  }

  void _drawOrb(
    Canvas canvas,
    Size size,
    double cxN,
    double cyN,
    double radius,
    Color color,
    double opacity,
  ) {
    final double cx = cxN.clamp(0.0, 1.0) * size.width;
    final double cy = cyN.clamp(0.0, 1.0) * size.height;

    final Paint paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          color.withOpacity(opacity),         // bright core
          color.withOpacity(opacity * 0.35),  // rapid mid-falloff
          color.withOpacity(0.0),             // clean transparent edge
        ],
        stops: const <double>[0.0, 0.28, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      );

    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(_AtmospherePainter old) {
    return (animValue - old.animValue).abs() > 0.002 ||
        old.glowScale != glowScale ||
        old.speedScale != speedScale ||
        old.colors[1] != colors[1];
  }
}
