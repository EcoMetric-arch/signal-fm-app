import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketStateData
// ─────────────────────────────────────────────────────────────────────────────

class MarketStateData {
  const MarketStateData({
    required this.label,
    required this.glowScale,
    required this.animSpeedScale,
    required this.peakScale,
    required this.shadowScale,
    required this.breatheScale,
    required this.aiDjMessage,
  });

  final String label;
  final double glowScale;
  final double animSpeedScale;
  final double peakScale;
  final double shadowScale;
  final double breatheScale;
  final String aiDjMessage;
}

abstract class MarketStates {
  static const MarketStateData calm = MarketStateData(
    label: 'Calm',
    glowScale: 0.6,
    animSpeedScale: 0.7,
    peakScale: 0.75,
    shadowScale: 0.6,
    breatheScale: 0.6,
    aiDjMessage: 'Market calm detected. Focus Flow Mix active.',
  );
  static const MarketStateData bullish = MarketStateData(
    label: 'Bullish',
    glowScale: 1.1,
    animSpeedScale: 1.0,
    peakScale: 1.0,
    shadowScale: 1.0,
    breatheScale: 1.0,
    aiDjMessage: 'Momentum confirmed. Adaptive groove locked in.',
  );
  static const MarketStateData breakout = MarketStateData(
    label: 'Breakout',
    glowScale: 1.7,
    animSpeedScale: 1.5,
    peakScale: 1.35,
    shadowScale: 1.5,
    breatheScale: 1.4,
    aiDjMessage: 'Momentum breakout confirmed. Energy mix engaged.',
  );
  static const MarketStateData panic = MarketStateData(
    label: 'Panic',
    glowScale: 1.9,
    animSpeedScale: 1.8,
    peakScale: 1.4,
    shadowScale: 1.8,
    breatheScale: 1.5,
    aiDjMessage: 'High volatility detected. Stabilization mode recommended.',
  );
  static const MarketStateData recovery = MarketStateData(
    label: 'Recovery',
    glowScale: 0.7,
    animSpeedScale: 0.65,
    peakScale: 0.70,
    shadowScale: 0.7,
    breatheScale: 0.55,
    aiDjMessage: 'Market in recovery. Breath mode active. Stay grounded.',
  );
  static const MarketStateData riskOff = MarketStateData(
    label: 'Risk-Off',
    glowScale: 0.8,
    animSpeedScale: 0.8,
    peakScale: 0.80,
    shadowScale: 0.85,
    breatheScale: 0.7,
    aiDjMessage: 'Risk-off environment. Low signal mode. Patience recommended.',
  );
  static const List<MarketStateData> all = [
    calm, bullish, breakout, panic, recovery, riskOff,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// AnalyticsData — Phase 6: adds insight line
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsData {
  const AnalyticsData({
    required this.bias,
    required this.volatility,
    required this.mtfAlignment,
    required this.aiMarketMood,
    required this.fearGreedMini,
    required this.fearGreedLabel,
    required this.r1,
    required this.now,
    required this.s1,
    required this.aiDjNote,
    required this.insight,
  });

  final String bias;
  final String volatility;
  final String mtfAlignment;
  final String aiMarketMood;
  final String fearGreedMini;
  final String fearGreedLabel; // e.g. "Neutral", "Greed", "Fear"
  final String r1;
  final String now;
  final String s1;
  final String aiDjNote;
  final String insight; // 2-line insight shown in analytics card
}

// ─────────────────────────────────────────────────────────────────────────────
// SessionMode — Phase 6: adds stationName
// ─────────────────────────────────────────────────────────────────────────────

class SessionMode {
  const SessionMode({
    required this.id,
    required this.displayName,
    required this.title,
    required this.stationName,
    required this.subtitle,
    required this.mood,
    required this.btcDelta,
    required this.fearIndex,
    required this.backgroundColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.quickModeIcon,
    required this.analytics,
    required this.waveformColors,
    required this.atmosphereColors,
    this.isDark = false,
  });

  final String id;
  final String displayName;
  final String title;
  final String stationName; // "Signal FM Radio" shown under title
  final String subtitle;
  final String mood;
  final String btcDelta;
  final String fearIndex;
  final Color backgroundColor;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData quickModeIcon;
  final AnalyticsData analytics;
  final bool isDark;
  final List<Color> waveformColors;
  final List<Color> atmosphereColors;

  bool get isNegativeDelta => btcDelta.startsWith('-');

  Color get onBackground =>
      isDark ? const Color(0xFFF0F2F5) : const Color(0xFF0F1623);
  Color get onBackgroundMuted =>
      isDark ? const Color(0xFF7A90A8) : const Color(0xFF556070);
  Color get surfaceColor => isDark
      ? Colors.white.withOpacity(0.07)
      : Colors.white.withOpacity(0.70);
  Color get surfaceBorder => isDark
      ? Colors.white.withOpacity(0.10)
      : Colors.white.withOpacity(0.86);
  Color get accentGlow => primaryColor.withOpacity(0.24);

  // Bias chip color — derived from bias string
  Color biasColor(String bias) {
    final b = bias.toLowerCase();
    if (b.contains('bull') || b.contains('risk-on')) {
      return const Color(0xFF22C55E);
    } else if (b.contains('bear') || b.contains('fear')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF94A3B8);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SignalFmSessions — Phase 6
// ─────────────────────────────────────────────────────────────────────────────

abstract class SignalFmSessions {
  // ── 1. London Open — dark elegant gold ────────────────────────────────────
  static const SessionMode londonOpen = SessionMode(
    id: 'London Open',
    displayName: 'London Open',
    title: 'London Open',
    stationName: 'Signal FM Radio',
    subtitle: 'Clarity. Focus. Precision.',
    mood: 'Focused',
    btcDelta: '+1.32%',
    fearIndex: '64',
    backgroundColor: Color(0xFF0D0F14),
    primaryColor: Color(0xFFD4A843),
    secondaryColor: Color(0xFF8B6914),
    quickModeIcon: Icons.wb_sunny_outlined,
    isDark: true,
    waveformColors: [Color(0xFF8B6914), Color(0xFFD4A843), Color(0xFFF5C842)],
    atmosphereColors: [
      Color(0xFF0A0B0E),
      Color(0xFF2A1F08),
      Color(0xFF3D2A0A),
      Color(0xFF0D0F14),
    ],
    analytics: AnalyticsData(
      bias: 'Bullish',
      volatility: 'Medium',
      mtfAlignment: '1D ↑  4H ↑  1H →',
      aiMarketMood: 'Risk-On',
      fearGreedMini: '64',
      fearGreedLabel: 'Focused',
      r1: r'$68,400',
      now: r'$67,892',
      s1: r'$66,100',
      aiDjNote: 'Momentum building in BTC. Focus mode recommended.',
      insight: 'Momentum building in BTC.\nFocus mode recommended.',
    ),
  );

  // ── 2. NY Momentum — electric blue ────────────────────────────────────────
  static const SessionMode nyMomentum = SessionMode(
    id: 'NY Momentum',
    displayName: 'NY Momentum',
    title: 'NY Momentum',
    stationName: 'Signal FM Radio',
    subtitle: 'Energy. Volatility. Movement.',
    mood: 'High Momentum',
    btcDelta: '+2.48%',
    fearIndex: '72',
    backgroundColor: Color(0xFF060E1C),
    primaryColor: Color(0xFF00A3FF),
    secondaryColor: Color(0xFF0057FF),
    quickModeIcon: Icons.bolt_outlined,
    isDark: true,
    waveformColors: [Color(0xFF004E8C), Color(0xFF0080D0), Color(0xFF00C2FF)],
    atmosphereColors: [
      Color(0xFF020810),
      Color(0xFF002B5C),
      Color(0xFF003F8A),
      Color(0xFF001A3D),
    ],
    analytics: AnalyticsData(
      bias: 'Strong Bull',
      volatility: 'High',
      mtfAlignment: '1D ↑  4H ↑  1H ↑',
      aiMarketMood: 'Risk-On',
      fearGreedMini: '72',
      fearGreedLabel: 'Greed',
      r1: r'$69,500',
      now: r'$67,892',
      s1: r'$66,800',
      aiDjNote: 'High-energy session. Volume surge detected. Stay sharp.',
      insight: 'Bullish momentum building.\nBreakout possible above \$68K.',
    ),
  );

  // ── 3. Tokyo Night — purple neon calm ─────────────────────────────────────
  static const SessionMode tokyoNight = SessionMode(
    id: 'Tokyo Night',
    displayName: 'Tokyo Night',
    title: 'Tokyo Night',
    stationName: 'Signal FM Radio',
    subtitle: 'Calm. Flow. Introspection.',
    mood: 'Calm',
    btcDelta: '-0.35%',
    fearIndex: '58',
    backgroundColor: Color(0xFF0D0620),
    primaryColor: Color(0xFFB06CFF),
    secondaryColor: Color(0xFF6D28D9),
    quickModeIcon: Icons.nightlight_outlined,
    isDark: true,
    waveformColors: [Color(0xFF4A1A80), Color(0xFF8B40D4), Color(0xFFCB9CFF)],
    atmosphereColors: [
      Color(0xFF080414),
      Color(0xFF200840),
      Color(0xFF1A0840),
      Color(0xFF0C0520),
    ],
    analytics: AnalyticsData(
      bias: 'Neutral',
      volatility: 'Low',
      mtfAlignment: '1D ↑  4H →  1H →',
      aiMarketMood: 'Cautious',
      fearGreedMini: '58',
      fearGreedLabel: 'Neutral',
      r1: r'$83,200',
      now: r'$67,892',
      s1: r'$80,800',
      aiDjNote: 'Low volatility window. Ideal for deep analysis.',
      insight: 'Market calm and stable.\nPerfect for deep introspection.',
    ),
  );

  // ── 4. Deep Focus — cyan/teal ─────────────────────────────────────────────
  static const SessionMode deepFocus = SessionMode(
    id: 'Deep Focus',
    displayName: 'Deep Focus',
    title: 'Deep Focus',
    stationName: 'Signal FM Radio',
    subtitle: 'Concentration. Flow State.',
    mood: 'Focused',
    btcDelta: '+0.18%',
    fearIndex: '66',
    backgroundColor: Color(0xFF050D14),
    primaryColor: Color(0xFF00E5CC),
    secondaryColor: Color(0xFF007A6E),
    quickModeIcon: Icons.track_changes_outlined,
    isDark: true,
    waveformColors: [Color(0xFF005C54), Color(0xFF00B8A0), Color(0xFF00FFE5)],
    atmosphereColors: [
      Color(0xFF030A10),
      Color(0xFF002E28),
      Color(0xFF004540),
      Color(0xFF020608),
    ],
    analytics: AnalyticsData(
      bias: 'Neutral',
      volatility: 'Very Low',
      mtfAlignment: '1D ↑  4H ↑  1H →',
      aiMarketMood: 'Calm',
      fearGreedMini: '66',
      fearGreedLabel: 'Greed',
      r1: r'$68,300',
      now: r'$67,892',
      s1: r'$67,500',
      aiDjNote: 'Clean structure. Key zones holding. Stay focused.',
      insight: 'Structure intact. Key levels holding.\nFocus. Execute. Stay calm.',
    ),
  );

  // ── 5. Recovery Mode — green/soft ─────────────────────────────────────────
  static const SessionMode recoveryMode = SessionMode(
    id: 'Recovery Mode',
    displayName: 'Recovery Mode',
    title: 'Recovery Mode',
    stationName: 'Signal FM Radio',
    subtitle: 'Reset. Recharge. Rebalance.',
    mood: 'Recovering',
    btcDelta: '-1.37%',
    fearIndex: '61',
    backgroundColor: Color(0xFF060E0A),
    primaryColor: Color(0xFF34D399),
    secondaryColor: Color(0xFF059669),
    quickModeIcon: Icons.self_improvement_outlined,
    isDark: true,
    waveformColors: [Color(0xFF065F46), Color(0xFF10B981), Color(0xFF6EE7B7)],
    atmosphereColors: [
      Color(0xFF030A06),
      Color(0xFF052A18),
      Color(0xFF073D24),
      Color(0xFF020608),
    ],
    analytics: AnalyticsData(
      bias: 'Bearish',
      volatility: 'High',
      mtfAlignment: '1D →  4H ↓  1H →',
      aiMarketMood: 'Cautious',
      fearGreedMini: '61',
      fearGreedLabel: 'Neutral',
      r1: r'$83,600',
      now: r'$67,892',
      s1: r'$80,900',
      aiDjNote: 'Market cooling down. Time to reset and recharge.',
      insight: 'Market cooling down.\nTime to reset and recharge.',
    ),
  );

  static const List<SessionMode> all = [
    londonOpen, nyMomentum, tokyoNight, deepFocus, recoveryMode,
  ];

  static SessionMode fromId(String id) => all.firstWhere(
        (s) => s.id == id,
        orElse: () => tokyoNight,
      );
}
