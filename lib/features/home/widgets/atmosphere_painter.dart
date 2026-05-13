import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AtmosphereLayer
//
// A full-screen ambient background painted with CustomPainter.
// Draws 3 soft radial orbs that drift in slow sine-wave paths.
// No images, no external packages.
//
// Design intent:
//   • London Open   → warm gold sunrise bloom, top-right drift
//   • NY Momentum   → cold electric blue, faster lateral drift
//   • Tokyo Night   → slow violet/indigo nebula drift
//   • Deep Focus    → near-still teal tunnel, minimal motion
//   • Recovery Mode → dim red-ember pulse, very slow
//
// MarketStateData.animSpeedScale multiplies the drift rate so Breakout /
// Panic states feel more alive, Calm / Recovery feel still and deliberate.
//
// Usage: Stack this behind everything else in the scaffold body.
//   Stack(children: [
//     const AtmosphereLayer(mode: _mode, marketState: _state),
//     ... content ...
//   ])
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
    // Base cycle: 18 seconds for one full drift loop. Feels cinematic, not bouncy.
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
        painter: _AtmospherePainter(
          colors: widget.mode.atmosphereColors,
          isDark: widget.mode.isDark,
          animValue: _ctrl.value,
          speedScale: widget.marketState.animSpeedScale,
          glowScale: widget.marketState.glowScale,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AtmospherePainter
// ─────────────────────────────────────────────────────────────────────────────

class _AtmospherePainter extends CustomPainter {
  _AtmospherePainter({
    required this.colors,
    required this.isDark,
    required this.animValue,
    required this.speedScale,
    required this.glowScale,
  });

  final List<Color> colors;   // 4-stop: base, mid, accent, rim
  final bool isDark;
  final double animValue;     // 0.0–1.0 repeating
  final double speedScale;    // from MarketStateData
  final double glowScale;     // from MarketStateData

  @override
  void paint(Canvas canvas, Size size) {
    final double t = animValue * speedScale;
    final w = size.width;
    final h = size.height;

    // ── Base fill (flat session background color) ─────────────────────
    // Not painted here — the scaffold backgroundColor handles it.
    // We only paint the orbs on top.

    // ── Orb definitions ───────────────────────────────────────────────
    // Each orb has:
    //   centerX/Y = normalized anchor (0–1) + slow sine drift
    //   radius    = fraction of screen diagonal
    //   color     = one of the 4 atmosphereColors stops
    //   opacity   = base opacity scaled by glowScale

    final diag = math.sqrt(w * w + h * h);

    final orbs = [
      // Orb 0 — large, slow, background bloom (mid color)
      _Orb(
        cx: 0.30 + 0.18 * math.sin(t * 2 * math.pi * 0.7),
        cy: 0.25 + 0.12 * math.cos(t * 2 * math.pi * 0.5),
        radius: diag * 0.52,
        color: colors[1],
        opacity: (isDark ? 0.28 : 0.22) * glowScale,
      ),
      // Orb 1 — medium, mid-speed, accent bloom
      _Orb(
        cx: 0.72 + 0.14 * math.cos(t * 2 * math.pi * 0.6),
        cy: 0.65 + 0.16 * math.sin(t * 2 * math.pi * 0.8),
        radius: diag * 0.38,
        color: colors[2],
        opacity: (isDark ? 0.20 : 0.15) * glowScale,
      ),
      // Orb 2 — small, faster, detail accent (rim color)
      _Orb(
        cx: 0.55 + 0.20 * math.sin(t * 2 * math.pi * 1.1 + 1.2),
        cy: 0.40 + 0.22 * math.cos(t * 2 * math.pi * 0.9 + 0.8),
        radius: diag * 0.24,
        color: colors[3],
        opacity: (isDark ? 0.14 : 0.10) * glowScale,
      ),
    ];

    for (final orb in orbs) {
      final cx = orb.cx.clamp(0.0, 1.0) * w;
      final cy = orb.cy.clamp(0.0, 1.0) * h;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            orb.color.withOpacity(orb.opacity),
            orb.color.withOpacity(0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(
          center: Offset(cx, cy),
          radius: orb.radius,
        ));

      canvas.drawCircle(Offset(cx, cy), orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_AtmospherePainter old) =>
      old.animValue != animValue ||
      old.glowScale != glowScale ||
      old.speedScale != speedScale ||
      old.colors[0] != colors[0];
}

class _Orb {
  const _Orb({
    required this.cx,
    required this.cy,
    required this.radius,
    required this.color,
    required this.opacity,
  });
  final double cx;
  final double cy;
  final double radius;
  final Color color;
  final double opacity;
}
