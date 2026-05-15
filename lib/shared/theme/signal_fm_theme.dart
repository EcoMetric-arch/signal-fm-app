import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dart compatibility: uses 'abstract class', NOT 'abstract final class'.
// No Dart records syntax. Compatible with Dart 2.17+ / Flutter 3.x.
// ─────────────────────────────────────────────────────────────────────────────

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
    glowScale: 0.55,
    animSpeedScale: 0.65,
    peakScale: 0.72,
    shadowScale: 0.55,
    breatheScale: 0.55,
    aiDjMessage: 'Market calm detected. Focus Flow Mix active.',
  );
  static const MarketStateData bullish = MarketStateData(
    label: 'Bullish',
    glowScale: 1.0,
    animSpeedScale: 1.0,
    peakScale: 1.0,
    shadowScale: 1.0,
    breatheScale: 1.0,
    aiDjMessage: 'Momentum confirmed. Adaptive groove locked in.',
  );
  static const MarketStateData breakout = MarketStateData(
    label: 'Breakout',
    glowScale: 1.6,
    animSpeedScale: 1.45,
    peakScale: 1.3,
    shadowScale: 1.4,
    breatheScale: 1.35,
    aiDjMessage: 'Momentum breakout confirmed. Energy mix engaged.',
  );
  static const MarketStateData panic = MarketStateData(
    label: 'Panic',
    glowScale: 1.8,
    animSpeedScale: 1.75,
    peakScale: 1.38,
    shadowScale: 1.7,
    breatheScale: 1.45,
    aiDjMessage: 'High volatility detected. Stabilization mode recommended.',
  );
  static const MarketStateData recovery = MarketStateData(
    label: 'Recovery',
    glowScale: 0.65,
    animSpeedScale: 0.60,
    peakScale: 0.68,
    shadowScale: 0.65,
    breatheScale: 0.52,
    aiDjMessage: 'Market in recovery. Breath mode active. Stay grounded.',
  );
  static const MarketStateData riskOff = MarketStateData(
    label: 'Risk-Off',
    glowScale: 0.75,
    animSpeedScale: 0.78,
    peakScale: 0.78,
    shadowScale: 0.80,
    breatheScale: 0.68,
    aiDjMessage: 'Risk-off environment. Low signal mode. Patience recommended.',
  );

  static const List<MarketStateData> all = <MarketStateData>[
    calm, bullish, breakout, panic, recovery, riskOff,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// AnalyticsData
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
  final String fearGreedLabel;
  final String r1;
  final String now;
  final String s1;
  final String aiDjNote;
  final String insight;
}

// ─────────────────────────────────────────────────────────────────────────────
// SessionMode
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
  final String stationName;
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

  /// 4 colors for AtmosphereLayer:
  ///   [0] void base (matches backgroundColor),
  ///   [1] primary orb (saturated accent),
  ///   [2] secondary bloom,
  ///   [3] rim/edge tint.
  final List<Color> atmosphereColors;

  bool get isNegativeDelta => btcDelta.startsWith('-');

  // ── Surface helpers ────────────────────────────────────────────────────────

  /// Crisp near-white primary text.
  Color get onBackground => const Color(0xFFF5F6FA);

  /// Muted secondary — clearly separated from primary.
  Color get onBackgroundMuted => const Color(0xFF6B82A0);

  /// Card fill: single translucent layer, no stacking.
  Color get surfaceColor => Colors.white.withOpacity(0.06);

  /// Hairline border — 0.13 for crisp 4K edge definition.
  Color get surfaceBorder => Colors.white.withOpacity(0.13);

  /// Top-edge highlight: simulates light on card top rim.
  Color get surfaceTopHighlight => Colors.white.withOpacity(0.18);

  /// Accent glow for card shadows.
  Color get accentGlow => primaryColor.withOpacity(0.35);

  /// Artwork ring glow — vivid core.
  Color get artworkGlow => primaryColor.withOpacity(0.60);

  Color biasColor(String bias) {
    final String b = bias.toLowerCase();
    if (b.contains('bull') || b.contains('risk-on') || b.contains('on')) {
      return const Color(0xFF23D96A);
    }
    if (b.contains('bear') || b.contains('fear') || b.contains('panic')) {
      return const Color(0xFFFF4D6A);
    }
    return const Color(0xFF8899BB);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SignalFmSessions
// ─────────────────────────────────────────────────────────────────────────────

abstract class SignalFmSessions {
  // ── 1. London Open — luxury dark gold ─────────────────────────────────────
  static const SessionMode londonOpen = SessionMode(
    id: 'London Open',
    displayName: 'London Open',
    title: 'London Open',
    stationName: 'Signal FM Radio',
    subtitle: 'Clarity. Focus. Precision.',
    mood: 'Focused',
    btcDelta: '+1.32%',
    fearIndex: '64',
    backgroundColor: Color(0xFF050608),
    primaryColor: Color(0xFFEDC55A),
    secondaryColor: Color(0xFF9A6E1A),
    quickModeIcon: Icons.wb_sunny_outlined,
    isDark: true,
    waveformColors: <Color>[
      Color(0xFF6A4208),
      Color(0xFFCC8E0A),
      Color(0xFFFFD84A),
    ],
    atmosphereColors: <Color>[
      Color(0xFF050608),
      Color(0xFFEDC55A),
      Color(0xFFB5780A),
      Color(0xFF3A2206),
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

  // ── 2. NY Momentum — electric cyber blue ──────────────────────────────────
  static const SessionMode nyMomentum = SessionMode(
    id: 'NY Momentum',
    displayName: 'NY Momentum',
    title: 'NY Momentum',
    stationName: 'Signal FM Radio',
    subtitle: 'Energy. Volatility. Movement.',
    mood: 'High Momentum',
    btcDelta: '+2.48%',
    fearIndex: '72',
    backgroundColor: Color(0xFF02060E),
    primaryColor: Color(0xFF12B0FF),
    secondaryColor: Color(0xFF0050CC),
    quickModeIcon: Icons.bolt_outlined,
    isDark: true,
    waveformColors: <Color>[
      Color(0xFF003080),
      Color(0xFF0070CC),
      Color(0xFF40D4FF),
    ],
    atmosphereColors: <Color>[
      Color(0xFF02060E),
      Color(0xFF12B0FF),
      Color(0xFF0060D4),
      Color(0xFF001440),
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

  // ── 3. Tokyo Night — vivid neon violet ────────────────────────────────────
  static const SessionMode tokyoNight = SessionMode(
    id: 'Tokyo Night',
    displayName: 'Tokyo Night',
    title: 'Tokyo Night',
    stationName: 'Signal FM Radio',
    subtitle: 'Calm. Flow. Introspection.',
    mood: 'Calm',
    btcDelta: '-0.35%',
    fearIndex: '58',
    backgroundColor: Color(0xFF04030C),
    primaryColor: Color(0xFFB86AFF),
    secondaryColor: Color(0xFF7228E0),
    quickModeIcon: Icons.nightlight_outlined,
    isDark: true,
    waveformColors: <Color>[
      Color(0xFF38107A),
      Color(0xFF8836E0),
      Color(0xFFE08AFF),
    ],
    atmosphereColors: <Color>[
      Color(0xFF04030C),
      Color(0xFFB86AFF),
      Color(0xFF7228E0),
      Color(0xFF180438),
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

  // ── 4. Deep Focus — premium cyan-teal ─────────────────────────────────────
  static const SessionMode deepFocus = SessionMode(
    id: 'Deep Focus',
    displayName: 'Deep Focus',
    title: 'Deep Focus',
    stationName: 'Signal FM Radio',
    subtitle: 'Concentration. Flow State.',
    mood: 'Focused',
    btcDelta: '+0.18%',
    fearIndex: '66',
    backgroundColor: Color(0xFF02080E),
    primaryColor: Color(0xFF00E2D6),
    secondaryColor: Color(0xFF007870),
    quickModeIcon: Icons.track_changes_outlined,
    isDark: true,
    waveformColors: <Color>[
      Color(0xFF004040),
      Color(0xFF00A898),
      Color(0xFF00F5E4),
    ],
    atmosphereColors: <Color>[
      Color(0xFF02080E),
      Color(0xFF00E2D6),
      Color(0xFF008878),
      Color(0xFF001420),
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

  // ── 5. Recovery Mode — vivid emerald ──────────────────────────────────────
  static const SessionMode recoveryMode = SessionMode(
    id: 'Recovery Mode',
    displayName: 'Recovery Mode',
    title: 'Recovery Mode',
    stationName: 'Signal FM Radio',
    subtitle: 'Reset. Recharge. Rebalance.',
    mood: 'Recovering',
    btcDelta: '-1.37%',
    fearIndex: '61',
    backgroundColor: Color(0xFF020805),
    primaryColor: Color(0xFF18E895),
    secondaryColor: Color(0xFF058858),
    quickModeIcon: Icons.self_improvement_outlined,
    isDark: true,
    waveformColors: <Color>[
      Color(0xFF044830),
      Color(0xFF0EC876),
      Color(0xFF60F5B0),
    ],
    atmosphereColors: <Color>[
      Color(0xFF020805),
      Color(0xFF18E895),
      Color(0xFF068A5C),
      Color(0xFF01180E),
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

  static const List<SessionMode> all = <SessionMode>[
    londonOpen, nyMomentum, tokyoNight, deepFocus, recoveryMode,
  ];

  static SessionMode fromId(String id) {
    return all.firstWhere(
      (SessionMode s) => s.id == id,
      orElse: () => tokyoNight,
    );
  }
}
