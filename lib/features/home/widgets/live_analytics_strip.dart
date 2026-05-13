import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LiveAnalyticsStrip  (Phase 3)
//
// Changes: each chip value wraps in AnimatedSwitcher(FadeTransition) so
// analytics values cross-fade when the session changes.
// Structure and layout are unchanged.
// ─────────────────────────────────────────────────────────────────────────────

class LiveAnalyticsStrip extends StatelessWidget {
  const LiveAnalyticsStrip({required this.mode, super.key});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnalyticsChipRow(mode: mode),
        const SizedBox(height: 10),
        _PriceMap(mode: mode),
        const SizedBox(height: 10),
        _AiDjNote(mode: mode),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnalyticsChipRow
// ─────────────────────────────────────────────────────────────────────────────

class _AnalyticsChipRow extends StatelessWidget {
  const _AnalyticsChipRow({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final a = mode.analytics;
    final chips = [
     {'label': 'BIAS', 'value': a.bias},
  {'label': 'VOL', 'value': a.volatility},
  {'label': 'MTF', 'value': a.mtfAlignment},
  {'label': 'MOOD', 'value': a.aiMarketMood},
  {'label': 'F&G', 'value': a.fearGreedMini},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final chip in chips) ...[
            _AnalyticsChip(
              label: chip['label']!,
              value: chip['value']!,
              sessionId: mode.id,
              mode: mode,
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _AnalyticsChip extends StatelessWidget {
  const _AnalyticsChip({
    required this.label,
    required this.value,
    required this.sessionId,
    required this.mode,
  });

  final String label;
  final String value;
  final String sessionId;
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: mode.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mode.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: mode.onBackgroundMuted,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: Text(
              value,
              key: ValueKey('$label$sessionId'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: mode.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PriceMap
// ─────────────────────────────────────────────────────────────────────────────

class _PriceMap extends StatelessWidget {
  const _PriceMap({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    final a = mode.analytics;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: mode.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mode.surfaceBorder, width: 1),
      ),
      child: Column(
        children: [
          _PriceZoneRow(
            label: 'R1',
            value: a.r1,
            dotColor: const Color(0xFF4CAF50),
            textColor: mode.onBackground,
            mutedColor: mode.onBackgroundMuted,
            sessionId: mode.id,
          ),
          const SizedBox(height: 6),
          _PriceZoneRow(
            label: 'NOW',
            value: a.now,
            dotColor: mode.primaryColor,
            textColor: mode.onBackground,
            mutedColor: mode.onBackgroundMuted,
            isNow: true,
            sessionId: mode.id,
          ),
          const SizedBox(height: 6),
          _PriceZoneRow(
            label: 'S1',
            value: a.s1,
            dotColor: const Color(0xFFFF5252),
            textColor: mode.onBackground,
            mutedColor: mode.onBackgroundMuted,
            sessionId: mode.id,
          ),
        ],
      ),
    );
  }
}

class _PriceZoneRow extends StatelessWidget {
  const _PriceZoneRow({
    required this.label,
    required this.value,
    required this.dotColor,
    required this.textColor,
    required this.mutedColor,
    required this.sessionId,
    this.isNow = false,
    super.key,
  });

  final String label;
  final String value;
  final Color dotColor;
  final Color textColor;
  final Color mutedColor;
  final bool isNow;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: isNow
                ? [BoxShadow(color: dotColor.withOpacity(0.5), blurRadius: 5)]
                : null,
          ),
        ),
        const SizedBox(width: 7),
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.4,
              color: isNow ? textColor : mutedColor,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dotColor.withOpacity(isNow ? 0.5 : 0.18),
                  dotColor.withOpacity(0.03),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Text(
            value,
            key: ValueKey('$label$sessionId'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              color: isNow ? textColor : mutedColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AiDjNote
// ─────────────────────────────────────────────────────────────────────────────

class _AiDjNote extends StatelessWidget {
  const _AiDjNote({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: mode.primaryColor.withOpacity(0.07),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        border: Border(
          left: BorderSide(color: mode.primaryColor, width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 10, color: mode.primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                mode.analytics.aiDjNote,
                key: ValueKey(mode.id),
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: mode.onBackground,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}