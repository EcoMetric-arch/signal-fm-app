import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LiveAnalyticsStrip  (Phase 6)
//
// Matches reference sections 8 + 9:
//
//   ┌─ LIVE ANALYTICS by ⬡ TraderaEdge ────────── ● LIVE ─┐
//   │  BIAS      VOLATILITY   MTF ALIGNMENT  AI MARKET MOOD  [AI orb] │
//   │  BULLISH   HIGH         1D↑ 4H↑ 1H→   RISK-ON               │
//   │──────────────────────────────────────────────────────────────│
//   │  INSIGHT                              FEAR & GREED           │
//   │  Market calm and stable.              ┌─────┐               │
//   │  Perfect for deep introspection.      │  58  │               │
//   │                                       │Neutral│               │
//   └──────────────────────────────────────────────────────────────┘
//
//   ┌─ PRICE MAP — KEY ZONES (BTC) ───────────────────────────────┐
//   │  R1  ●━━━━━━━━━━━━━━━━━━━━━━━━━━━━  $83,200               │
//   │  NOW  ●━━━━━━━━━━━━━━━━━━━━━━━━  $67,892                  │
//   │  S1  ●━━━━━━━━━━━━━━━━━━━━━━━  $80,800                    │
//   └──────────────────────────────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────

class LiveAnalyticsStrip extends StatelessWidget {
  const LiveAnalyticsStrip({required this.mode, super.key});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Analytics card ────────────────────────────────────────────
        _AnalyticsCard(mode: mode),

        const SizedBox(height: 10),

        // ── Price map card ────────────────────────────────────────────
        _PriceMapCard(mode: mode),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnalyticsCard
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final a = mode.analytics;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: mode.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mode.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: mode.primaryColor.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          _CardHeader(mode: mode),

          const SizedBox(height: 10),

          // ── 4 chips + AI avatar ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _AnalyticsChip(
                      label: 'BIAS',
                      value: a.bias.toUpperCase(),
                      valueColor: mode.biasColor(a.bias),
                      mode: mode,
                    ),
                    const SizedBox(width: 6),
                    _AnalyticsChip(
                      label: 'VOLATILITY',
                      value: a.volatility.toUpperCase(),
                      valueColor: a.volatility.toLowerCase().contains('high')
                          ? const Color(0xFFEF4444)
                          : a.volatility.toLowerCase().contains('low')
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFF59E0B),
                      mode: mode,
                    ),
                    const SizedBox(width: 6),
                    _AnalyticsChip(
                      label: 'MTF ALIGNMENT',
                      value: a.mtfAlignment,
                      valueColor: mode.primaryColor,
                      mode: mode,
                      compact: true,
                    ),
                    const SizedBox(width: 6),
                    _AnalyticsChip(
                      label: 'AI MARKET MOOD',
                      value: a.aiMarketMood.toUpperCase(),
                      valueColor: mode.biasColor(a.aiMarketMood),
                      mode: mode,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // AI orb avatar
              _AiOrb(mode: mode),
            ],
          ),

          const SizedBox(height: 10),
          Container(height: 1, color: mode.surfaceBorder),
          const SizedBox(height: 10),

          // ── Insight + Fear & Greed ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INSIGHT',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: mode.onBackgroundMuted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 340),
                      child: Text(
                        a.insight,
                        key: ValueKey(mode.id),
                        style: TextStyle(
                          fontSize: 12,
                          color: mode.onBackground,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _FearGreedGauge(mode: mode),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CardHeader — "LIVE ANALYTICS by ⬡ TraderaEdge" + LIVE dot
// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatefulWidget {
  const _CardHeader({required this.mode});
  final SessionMode mode;

  @override
  State<_CardHeader> createState() => _CardHeaderState();
}

class _CardHeaderState extends State<_CardHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    return Row(
      children: [
        // Brand icon
        Icon(Icons.analytics_outlined, size: 13, color: mode.primaryColor),
        const SizedBox(width: 5),
        Text(
          'LIVE ANALYTICS  ',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: mode.onBackgroundMuted,
          ),
        ),
        Text(
          'by  TraderaEdge',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: mode.onBackground,
          ),
        ),
        const Spacer(),
        // LIVE badge
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF22C55E)
                      .withOpacity(_pulse.value),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF22C55E)
                      .withOpacity(_pulse.value),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnalyticsChip
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyticsChip extends StatelessWidget {
  const _AnalyticsChip({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.mode,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final SessionMode mode;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: mode.onBackgroundMuted,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: Text(
              value,
              key: ValueKey('$label${mode.id}'),
              style: TextStyle(
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w800,
                color: valueColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 3),
          // Tiny underline bar in value color
          Container(
            height: 1.5,
            width: 20,
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AiOrb — small AI avatar orb, pulsing
// ─────────────────────────────────────────────────────────────────────────────

class _AiOrb extends StatefulWidget {
  const _AiOrb({required this.mode});
  final SessionMode mode;

  @override
  State<_AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<_AiOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              mode.primaryColor
                  .withOpacity(0.3 + _ctrl.value * 0.2),
              mode.primaryColor.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: mode.primaryColor
                .withOpacity(0.4 + _ctrl.value * 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 16,
          color: mode.primaryColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FearGreedGauge — circular gauge in the insight section
// ─────────────────────────────────────────────────────────────────────────────

class _FearGreedGauge extends StatelessWidget {
  const _FearGreedGauge({required this.mode});
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'FEAR & GREED',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: mode.onBackgroundMuted,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 58,
          height: 58,
          child: CustomPaint(
            painter: _GaugePainter(score: score, color: scoreColor),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: Text(
                      '$score',
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    const startAngle = math.pi * 0.75;
    const sweepTotal = math.pi * 1.5;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      Paint()
        ..color = color.withOpacity(0.15)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Value arc
    final sweep = sweepTotal * (score / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _PriceMapCard — R1 / NOW / S1
// ─────────────────────────────────────────────────────────────────────────────

class _PriceMapCard extends StatelessWidget {
  const _PriceMapCard({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final a = mode.analytics;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: mode.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mode.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRICE MAP — KEY ZONES (BTC)',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: mode.onBackgroundMuted,
            ),
          ),
          const SizedBox(height: 10),
          _PriceZone(
            label: 'R1',
            value: a.r1,
            dotColor: const Color(0xFFEF4444),
            lineProgress: 0.78,
            textColor: mode.onBackground,
            mutedColor: mode.onBackgroundMuted,
            sessionId: mode.id,
          ),
          const SizedBox(height: 8),
          _PriceZone(
            label: 'NOW',
            value: a.now,
            dotColor: mode.primaryColor,
            lineProgress: 0.55,
            textColor: mode.onBackground,
            mutedColor: mode.onBackgroundMuted,
            sessionId: mode.id,
            isNow: true,
          ),
          const SizedBox(height: 8),
          _PriceZone(
            label: 'S1',
            value: a.s1,
            dotColor: const Color(0xFF22C55E),
            lineProgress: 0.68,
            textColor: mode.onBackground,
            mutedColor: mode.onBackgroundMuted,
            sessionId: mode.id,
          ),
        ],
      ),
    );
  }
}

class _PriceZone extends StatelessWidget {
  const _PriceZone({
    required this.label,
    required this.value,
    required this.dotColor,
    required this.lineProgress,
    required this.textColor,
    required this.mutedColor,
    required this.sessionId,
    this.isNow = false,
    super.key,
  });

  final String label;
  final String value;
  final Color dotColor;
  final double lineProgress;
  final Color textColor;
  final Color mutedColor;
  final String sessionId;
  final bool isNow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Label
        SizedBox(
          width: 30,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: dotColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Dot
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            boxShadow: [
              BoxShadow(
                color: dotColor.withOpacity(0.5),
                blurRadius: isNow ? 6 : 3,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Line
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => Stack(
              children: [
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: dotColor.withOpacity(0.15),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * lineProgress,
                  height: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          dotColor.withOpacity(0.8),
                          dotColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Price
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: Text(
            value,
            key: ValueKey('$label$sessionId'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              color: isNow ? textColor : mutedColor,
            ),
          ),
        ),
      ],
    );
  }
}
