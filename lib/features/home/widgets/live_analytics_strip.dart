import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LiveAnalyticsStrip — Analytics card + Price Map card
// Dart compatibility: Dart 2.17+, no records, no abstract final class.
// ─────────────────────────────────────────────────────────────────────────────

class LiveAnalyticsStrip extends StatelessWidget {
  const LiveAnalyticsStrip({required this.mode, super.key});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _AnalyticsCard(mode: mode),
        const SizedBox(height: 8),
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
    final AnalyticsData a = mode.analytics;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: mode.primaryColor.withOpacity(0.10),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CardHeader(mode: mode),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _Chip(
                      label: 'BIAS',
                      value: a.bias.toUpperCase(),
                      color: mode.biasColor(a.bias),
                    ),
                    const SizedBox(width: 6),
                    _Chip(
                      label: 'VOLATILITY',
                      value: a.volatility.toUpperCase(),
                      color: _volatilityColor(a.volatility),
                    ),
                    const SizedBox(width: 6),
                    _Chip(
                      label: 'MTF',
                      value: a.mtfAlignment,
                      color: mode.primaryColor,
                      compact: true,
                    ),
                    const SizedBox(width: 6),
                    _Chip(
                      label: 'MOOD',
                      value: a.aiMarketMood.toUpperCase(),
                      color: mode.biasColor(a.aiMarketMood),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _AiOrb(mode: mode),
            ],
          ),
          const SizedBox(height: 9),
          Container(height: 1, color: Colors.white.withOpacity(0.10)),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'INSIGHT',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: Color(0xFF6B82A0),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      child: Text(
                        a.insight,
                        key: ValueKey<String>(mode.id),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFE8ECF4),
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

  static Color _volatilityColor(String v) {
    final String lower = v.toLowerCase();
    if (lower.contains('high')) return const Color(0xFFFF4D6A);
    if (lower.contains('low')) return const Color(0xFF23D96A);
    return const Color(0xFFF59E0B);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CardHeader — pulsing LIVE dot
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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SessionMode mode = widget.mode;
    return Row(
      children: <Widget>[
        Icon(Icons.analytics_outlined, size: 12, color: mode.primaryColor),
        const SizedBox(width: 5),
        const Text(
          'LIVE ANALYTICS  ',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Color(0xFF6B82A0),
          ),
        ),
        const Text(
          'by  TraderaEdge',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFFD0D8E8),
          ),
        ),
        const Spacer(),
        AnimatedBuilder(
          animation: _pulse,
          builder: (BuildContext context, Widget? child) {
            return Row(
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF23D96A)
                        .withOpacity(_pulse.value),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF23D96A)
                            .withOpacity(_pulse.value * 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF23D96A)
                        .withOpacity(_pulse.value),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Chip
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF6B82A0),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 9 : 12,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AiOrb
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
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SessionMode mode = widget.mode;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mode.primaryColor.withOpacity(0.12),
            border: Border.all(
              color: mode.primaryColor
                  .withOpacity(0.30 + _ctrl.value * 0.25),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: mode.primaryColor
                    .withOpacity(0.20 + _ctrl.value * 0.15),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 15,
            color: mode.primaryColor,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FearGreedGauge
// ─────────────────────────────────────────────────────────────────────────────

class _FearGreedGauge extends StatelessWidget {
  const _FearGreedGauge({required this.mode});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final int score =
        int.tryParse(mode.analytics.fearGreedMini) ?? 50;
    final Color c = _scoreColor(score, mode.primaryColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Text(
          'FEAR & GREED',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: Color(0xFF6B82A0),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 56,
          height: 56,
          child: CustomPaint(
            painter: _GaugePainter(score: score, color: c),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: c,
                      height: 1.0,
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
            ),
          ),
        ),
      ],
    );
  }

  static Color _scoreColor(int score, Color primary) {
    if (score <= 30) return const Color(0xFFFF4D6A);
    if (score <= 50) return const Color(0xFFF59E0B);
    if (score <= 70) return primary;
    return const Color(0xFF23D96A);
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4;
    const double startAngle = math.pi * 0.75;
    const double sweepTotal = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepTotal, false,
      Paint()
        ..color = Colors.white.withOpacity(0.10)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepTotal * (score / 100), false,
      Paint()
        ..color = color
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) {
    return old.score != score || old.color != color;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PriceMapCard
// ─────────────────────────────────────────────────────────────────────────────

class _PriceMapCard extends StatelessWidget {
  const _PriceMapCard({required this.mode});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final AnalyticsData a = mode.analytics;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'PRICE MAP — KEY ZONES (BTC)',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: Color(0xFF6B82A0),
            ),
          ),
          const SizedBox(height: 9),
          _Zone(
            label: 'R1',
            value: a.r1,
            dotColor: const Color(0xFFFF4D6A),
            progress: 0.78,
            sessionId: mode.id,
          ),
          const SizedBox(height: 7),
          _Zone(
            label: 'NOW',
            value: a.now,
            dotColor: mode.primaryColor,
            progress: 0.55,
            sessionId: mode.id,
            isNow: true,
          ),
          const SizedBox(height: 7),
          _Zone(
            label: 'S1',
            value: a.s1,
            dotColor: const Color(0xFF23D96A),
            progress: 0.68,
            sessionId: mode.id,
          ),
        ],
      ),
    );
  }
}

class _Zone extends StatelessWidget {
  const _Zone({
    required this.label,
    required this.value,
    required this.dotColor,
    required this.progress,
    required this.sessionId,
    this.isNow = false,
    super.key,
  });

  final String label;
  final String value;
  final Color dotColor;
  final double progress;
  final String sessionId;
  final bool isNow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: dotColor,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            boxShadow: isNow
                ? <BoxShadow>[
                    BoxShadow(
                        color: dotColor.withOpacity(0.60), blurRadius: 7),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              return Stack(
                children: <Widget>[
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Container(
                    height: 2,
                    width: c.maxWidth * progress,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: dotColor.withOpacity(0.75),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: Text(
            value,
            key: ValueKey<String>('$label$sessionId'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              color: isNow
                  ? const Color(0xFFF5F6FA)
                  : const Color(0xFF8899BB),
            ),
          ),
        ),
      ],
    );
  }
}
