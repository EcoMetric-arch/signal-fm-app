import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LiveAnalyticsStrip — Phase 7: cockpit module
//
// Phase 7 changes vs Phase 6:
//   • 7-field cockpit row: BIAS · VOL · FUND · OI · BTC.D · ATR · STATE
//     (was 4 fields: BIAS · VOL · MTF · MOOD)
//   • Market State chip — visible, color-coded, placed in header right
//   • Cockpit section header: "MARKET INTELLIGENCE" instead of decorative
//   • Price map preserved, tightened
//   • Insight line preserved
//   • Two-card structure collapses into one unified cockpit card
//     with internal dividers — less "stacked sections" feel
//
// Phase 8 integration points (marked with // [PHASE 8]):
//   • Replace mode.analytics.* fields with AsyncValue from MarketProvider
//   • Replace price zones with live WebSocket values
// ─────────────────────────────────────────────────────────────────────────────

class LiveAnalyticsStrip extends StatelessWidget {
  const LiveAnalyticsStrip({
    required this.mode,
    required this.marketState,
    super.key,
  });

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    return _CockpitCard(mode: mode, marketState: marketState);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CockpitCard — one unified card: header + 7 chips + divider + price map
// ─────────────────────────────────────────────────────────────────────────────

class _CockpitCard extends StatelessWidget {
  const _CockpitCard({required this.mode, required this.marketState});

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    final AnalyticsData a = mode.analytics;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
          // ── Header ──────────────────────────────────────────────────
          _CockpitHeader(mode: mode, marketState: marketState),

          const SizedBox(height: 9),

          // ── 7-field cockpit row ──────────────────────────────────────
          _CockpitMetricsRow(mode: mode, a: a),

          const SizedBox(height: 9),

          // ── Divider ──────────────────────────────────────────────────
          Container(height: 1, color: Colors.white.withOpacity(0.08)),

          const SizedBox(height: 9),

          // ── Insight + F&G gauge ──────────────────────────────────────
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

          const SizedBox(height: 9),
          Container(height: 1, color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 9),

          // ── Price map ────────────────────────────────────────────────
          _PriceMapSection(mode: mode),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CockpitHeader — "MARKET INTELLIGENCE by TraderaEdge" + state chip + LIVE
// ─────────────────────────────────────────────────────────────────────────────

class _CockpitHeader extends StatefulWidget {
  const _CockpitHeader({required this.mode, required this.marketState});

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  State<_CockpitHeader> createState() => _CockpitHeaderState();
}

class _CockpitHeaderState extends State<_CockpitHeader>
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
    final MarketStateData ms = widget.marketState;

    return Row(
      children: <Widget>[
        // Icon
        Icon(Icons.analytics_outlined, size: 11, color: mode.primaryColor),
        const SizedBox(width: 5),
        // Label
        const Text(
          'MARKET INTELLIGENCE',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
            color: Color(0xFF6B82A0),
          ),
        ),
        const SizedBox(width: 5),
        // TraderaEdge tag
        Text(
          'TraderaEdge',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: mode.primaryColor.withOpacity(0.70),
          ),
        ),
        const Spacer(),

        // ── Market State chip ────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: Container(
            key: ValueKey<String>(ms.label),
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: ms.stateColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ms.stateColor.withOpacity(0.40),
                width: 1,
              ),
            ),
            child: Text(
              ms.label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: ms.stateColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── LIVE dot ─────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _pulse,
          builder: (BuildContext context, Widget? child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF23D96A)
                        .withOpacity(_pulse.value),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF23D96A)
                            .withOpacity(_pulse.value * 0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 8,
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
// _CockpitMetricsRow — 7 fields: BIAS VOL FUND OI BTC.D ATR STATE
// ─────────────────────────────────────────────────────────────────────────────

class _CockpitMetricsRow extends StatelessWidget {
  const _CockpitMetricsRow({required this.mode, required this.a});

  final SessionMode mode;
  final AnalyticsData a;

  @override
  Widget build(BuildContext context) {
    // Build metric definitions
    // [PHASE 8]: replace a.* with live provider values
    final List<_MetricDef> metrics = <_MetricDef>[
      _MetricDef(
        label: 'BIAS',
        value: a.bias.toUpperCase(),
        color: mode.biasColor(a.bias),
      ),
      _MetricDef(
        label: 'VOL',
        value: a.volatility.toUpperCase(),
        color: _volColor(a.volatility),
      ),
      _MetricDef(
        label: 'FUND',
        value: a.funding,
        color: a.funding.startsWith('-')
            ? const Color(0xFFFF4D6A)
            : const Color(0xFF23D96A),
      ),
      _MetricDef(
        label: 'OI',
        value: a.openInterest,
        color: mode.primaryColor,
      ),
      _MetricDef(
        label: 'BTC.D',
        value: a.btcDominance,
        color: const Color(0xFFF59E0B),
      ),
      _MetricDef(
        label: 'ATR',
        value: a.atr,
        color: mode.onBackground,
      ),
      _MetricDef(
        label: 'MTF',
        value: a.mtfAlignment,
        color: mode.primaryColor,
        compact: true,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < metrics.length; i++) ...<Widget>[
            _MetricCell(
              def: metrics[i],
              sessionId: mode.id,
            ),
            if (i < metrics.length - 1)
              Container(
                width: 1,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white.withOpacity(0.08),
              ),
          ],
        ],
      ),
    );
  }

  static Color _volColor(String v) {
    final String l = v.toLowerCase();
    if (l.contains('high')) return const Color(0xFFFF4D6A);
    if (l.contains('low')) return const Color(0xFF23D96A);
    return const Color(0xFFF59E0B);
  }
}

class _MetricDef {
  const _MetricDef({
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool compact;
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.def, required this.sessionId});

  final _MetricDef def;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          def.label,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Color(0xFF6B82A0),
          ),
        ),
        const SizedBox(height: 3),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: Text(
            def.value,
            key: ValueKey<String>('${def.label}$sessionId'),
            style: TextStyle(
              fontSize: def.compact ? 9 : 11,
              fontWeight: FontWeight.w800,
              color: def.color,
              letterSpacing: 0.1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 16,
          decoration: BoxDecoration(
            color: def.color.withOpacity(0.70),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FearGreedGauge — arc gauge (unchanged from final)
// ─────────────────────────────────────────────────────────────────────────────

class _FearGreedGauge extends StatelessWidget {
  const _FearGreedGauge({required this.mode});

  final SessionMode mode;

  static Color _scoreColor(int score, Color primary) {
    if (score <= 30) return const Color(0xFFFF4D6A);
    if (score <= 50) return const Color(0xFFF59E0B);
    if (score <= 70) return primary;
    return const Color(0xFF23D96A);
  }

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
          width: 54,
          height: 54,
          child: CustomPaint(
            painter: _GaugePainter(score: score, color: c),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 15,
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
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 4;
    const double start = math.pi * 0.75;
    const double sweep = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start, sweep, false,
      Paint()
        ..color = Colors.white.withOpacity(0.10)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start, sweep * (score / 100), false,
      Paint()
        ..color = color
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.score != score || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// _PriceMapSection — R1 / NOW / S1 (unchanged from final)
// ─────────────────────────────────────────────────────────────────────────────

class _PriceMapSection extends StatelessWidget {
  const _PriceMapSection({required this.mode});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final AnalyticsData a = mode.analytics;
    return Column(
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
        const SizedBox(height: 8),
        _Zone(
          label: 'R1', value: a.r1,
          dotColor: const Color(0xFFFF4D6A),
          progress: 0.78, sessionId: mode.id,
        ),
        const SizedBox(height: 6),
        _Zone(
          label: 'NOW', value: a.now,
          dotColor: mode.primaryColor,
          progress: 0.55, sessionId: mode.id, isNow: true,
        ),
        const SizedBox(height: 6),
        _Zone(
          label: 'S1', value: a.s1,
          dotColor: const Color(0xFF23D96A),
          progress: 0.68, sessionId: mode.id,
        ),
      ],
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            boxShadow: isNow
                ? <BoxShadow>[
                    BoxShadow(
                        color: dotColor.withOpacity(0.60), blurRadius: 6),
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
