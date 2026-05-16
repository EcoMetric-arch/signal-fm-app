import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dart compatibility: abstract class (NOT abstract final class). Dart 2.17+.
// No Dart records syntax.
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// MarketFeedData — mock live feed row
// Phase 7: Architecture-aligned. 8 instruments from spec.
// Phase 8: Replace mock values with WebSocket feed.
// ─────────────────────────────────────────────────────────────────────────────

class MarketFeedItem {
  const MarketFeedItem({
    required this.symbol,
    required this.value,
    required this.delta,
    required this.isPositive,
  });

  final String symbol;
  final String value;
  final String delta;
  final bool isPositive;
}

abstract class MockMarketFeed {
  /// Phase 7 mock values for the live feed strip.
  /// Phase 8: replace with Stream<List<MarketFeedItem>> from WebSocket.
  static List<MarketFeedItem> forSession(String sessionId) {
    final bool bullish =
        sessionId == 'NY Momentum' || sessionId == 'London Open';
    return <MarketFeedItem>[
      MarketFeedItem(
        symbol: 'BTC',
        value: '\$67,892',
        delta: bullish ? '+2.1%' : '-0.4%',
        isPositive: bullish,
      ),
      MarketFeedItem(
        symbol: 'ETH',
        value: '\$3,541',
        delta: bullish ? '+1.8%' : '-0.6%',
        isPositive: bullish,
      ),
      MarketFeedItem(
        symbol: 'TOTAL3',
        value: '\$612B',
        delta: bullish ? '+2.4%' : '-1.1%',
        isPositive: bullish,
      ),
      MarketFeedItem(
        symbol: 'BTC.D',
        value: '54.2%',
        delta: '+0.3%',
        isPositive: true,
      ),
      MarketFeedItem(
        symbol: 'FUND',
        value: '0.012%',
        delta: bullish ? '+' : '-',
        isPositive: bullish,
      ),
      MarketFeedItem(
        symbol: 'OI',
        value: '\$18.4B',
        delta: bullish ? '+3.2%' : '-1.4%',
        isPositive: bullish,
      ),
      MarketFeedItem(
        symbol: 'F&G',
        value: bullish ? '72' : '48',
        delta: bullish ? 'Greed' : 'Neutral',
        isPositive: bullish,
      ),
      MarketFeedItem(
        symbol: 'VOL',
        value: bullish ? 'HIGH' : 'LOW',
        delta: '',
        isPositive: bullish,
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MarketStateData — Phase 7: adds aiDjEngineNote (what the engine is doing)
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
    required this.aiDjEngineNote,
    required this.stateColor,
  });

  final String label;
  final double glowScale;
  final double animSpeedScale;
  final double peakScale;
  final double shadowScale;
  final double breatheScale;

  /// Short ambient message shown in AiDjBar.
  final String aiDjMessage;

  /// Technical engine note — what the AI DJ is actually doing.
  /// Example: "Reducing ambience density. Focus layer active."
  final String aiDjEngineNote;

  /// Visual color for the state chip.
  final Color stateColor;
}

abstract class MarketStates {
  static const MarketStateData calm = MarketStateData(
    label: 'CALM',
    glowScale: 0.55,
    animSpeedScale: 0.65,
    peakScale: 0.72,
    shadowScale: 0.55,
    breatheScale: 0.55,
    aiDjMessage: 'Market calm detected. Focus Flow Mix active.',
    aiDjEngineNote: 'Low volatility. Reducing ambience density. Breath layer on.',
    stateColor: Color(0xFF8899BB),
  );

  static const MarketStateData bullish = MarketStateData(
    label: 'BULLISH',
    glowScale: 1.0,
    animSpeedScale: 1.0,
    peakScale: 1.0,
    shadowScale: 1.0,
    breatheScale: 1.0,
    aiDjMessage: 'Momentum confirmed. Adaptive groove locked in.',
    aiDjEngineNote: 'Momentum active. Energy layers scaling. Pulse aligned.',
    stateColor: Color(0xFF23D96A),
  );

  static const MarketStateData breakout = MarketStateData(
    label: 'BREAKOUT',
    glowScale: 1.6,
    animSpeedScale: 1.45,
    peakScale: 1.3,
    shadowScale: 1.4,
    breatheScale: 1.35,
    aiDjMessage: 'Momentum breakout confirmed. Energy mix engaged.',
    aiDjEngineNote: 'Breakout detected. Max energy. Particle speed elevated.',
    stateColor: Color(0xFFF59E0B),
  );

  static const MarketStateData panic = MarketStateData(
    label: 'PANIC',
    glowScale: 1.8,
    animSpeedScale: 1.75,
    peakScale: 1.38,
    shadowScale: 1.7,
    breatheScale: 1.45,
    aiDjMessage: 'High volatility detected. Stabilization mode recommended.',
    aiDjEngineNote: 'Volatility rising. Stabilization layer active. Glow at max.',
    stateColor: Color(0xFFFF4D6A),
  );

  static const MarketStateData recovery = MarketStateData(
    label: 'RECOVERY',
    glowScale: 0.65,
    animSpeedScale: 0.60,
    peakScale: 0.68,
    shadowScale: 0.65,
    breatheScale: 0.52,
    aiDjMessage: 'Market in recovery. Breath mode active. Stay grounded.',
    aiDjEngineNote: 'Recovery phase. Ambience softening. Slow pulse engaged.',
    stateColor: Color(0xFF34D399),
  );

  static const MarketStateData riskOff = MarketStateData(
    label: 'RISK-OFF',
    glowScale: 0.75,
    animSpeedScale: 0.78,
    peakScale: 0.78,
    shadowScale: 0.80,
    breatheScale: 0.68,
    aiDjMessage: 'Risk-off environment. Low signal mode. Patience recommended.',
    aiDjEngineNote: 'Risk-off signal. Dimming layers. Minimal pulse mode.',
    stateColor: Color(0xFF6B82A0),
  );

  static const List<MarketStateData> all = <MarketStateData>[
    calm, bullish, breakout, panic, recovery, riskOff,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// AnalyticsData — Phase 7: expanded to full market cockpit
// New fields: funding, openInterest, btcDominance, atr, marketState
// Phase 8: all fields become live-feed values
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsData {
  const AnalyticsData({
    required this.bias,
    required this.volatility,
    required this.mtfAlignment,
    required this.aiMarketMood,
    required this.fearGreedMini,
    required this.fearGreedLabel,
    // Phase 7 new cockpit fields
    required this.funding,
    required this.openInterest,
    required this.btcDominance,
    required this.atr,
    required this.marketStateName,
    // Price map
    required this.r1,
    required this.now,
    required this.s1,
    // AI
    required this.aiDjNote,
    required this.insight,
  });

  final String bias;
  final String volatility;
  final String mtfAlignment;
  final String aiMarketMood;
  final String fearGreedMini;
  final String fearGreedLabel;

  // Phase 7 market cockpit fields
  final String funding;       // e.g. "+0.012%"
  final String openInterest;  // e.g. "$18.4B"
  final String btcDominance;  // e.g. "54.2%"
  final String atr;           // e.g. "$1,240"
  final String marketStateName; // e.g. "BULLISH"

  // Price map
  final String r1;
  final String now;
  final String s1;

  // AI
  final String aiDjNote;
  final String insight;
}

// ─────────────────────────────────────────────────────────────────────────────
// SessionMode — unchanged structure, analytics expanded
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
  final List<Color> atmosphereColors;

  bool get isNegativeDelta => btcDelta.startsWith('-');

  Color get onBackground => const Color(0xFFF5F6FA);
  Color get onBackgroundMuted => const Color(0xFF6B82A0);
  Color get surfaceColor => Colors.white.withOpacity(0.06);
  Color get surfaceBorder => Colors.white.withOpacity(0.13);
  Color get surfaceTopHighlight => Colors.white.withOpacity(0.18);
  Color get accentGlow => primaryColor.withOpacity(0.35);
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
// SignalFmSessions — Phase 7: all AnalyticsData expanded with new fields
// ─────────────────────────────────────────────────────────────────────────────

abstract class SignalFmSessions {
  // ── 1. London Open ─────────────────────────────────────────────────────────
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
      Color(0xFF6A4208), Color(0xFFCC8E0A), Color(0xFFFFD84A),
    ],
    atmosphereColors: <Color>[
      Color(0xFF050608), Color(0xFFEDC55A), Color(0xFFB5780A), Color(0xFF3A2206),
    ],
    analytics: AnalyticsData(
      bias: 'Bullish',
      volatility: 'Medium',
      mtfAlignment: '1D ↑  4H ↑  1H →',
      aiMarketMood: 'Risk-On',
      fearGreedMini: '64',
      fearGreedLabel: 'Focused',
      funding: '+0.012%',
      openInterest: '\$18.4B',
      btcDominance: '54.2%',
      atr: '\$1,240',
      marketStateName: 'BULLISH',
      r1: r'$68,400',
      now: r'$67,892',
      s1: r'$66,100',
      aiDjNote: 'Momentum building in BTC. Focus mode recommended.',
      insight: 'Momentum building in BTC.\nFocus mode recommended.',
    ),
  );

  // ── 2. NY Momentum ─────────────────────────────────────────────────────────
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
      Color(0xFF003080), Color(0xFF0070CC), Color(0xFF40D4FF),
    ],
    atmosphereColors: <Color>[
      Color(0xFF02060E), Color(0xFF12B0FF), Color(0xFF0060D4), Color(0xFF001440),
    ],
    analytics: AnalyticsData(
      bias: 'Strong Bull',
      volatility: 'High',
      mtfAlignment: '1D ↑  4H ↑  1H ↑',
      aiMarketMood: 'Risk-On',
      fearGreedMini: '72',
      fearGreedLabel: 'Greed',
      funding: '+0.031%',
      openInterest: '\$22.1B',
      btcDominance: '53.8%',
      atr: '\$1,890',
      marketStateName: 'BREAKOUT',
      r1: r'$69,500',
      now: r'$67,892',
      s1: r'$66,800',
      aiDjNote: 'High-energy session. Volume surge detected. Stay sharp.',
      insight: 'Bullish momentum building.\nBreakout possible above \$68K.',
    ),
  );

  // ── 3. Tokyo Night ─────────────────────────────────────────────────────────
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
      Color(0xFF38107A), Color(0xFF8836E0), Color(0xFFE08AFF),
    ],
    atmosphereColors: <Color>[
      Color(0xFF04030C), Color(0xFFB86AFF), Color(0xFF7228E0), Color(0xFF180438),
    ],
    analytics: AnalyticsData(
      bias: 'Neutral',
      volatility: 'Low',
      mtfAlignment: '1D ↑  4H →  1H →',
      aiMarketMood: 'Cautious',
      fearGreedMini: '58',
      fearGreedLabel: 'Neutral',
      funding: '+0.005%',
      openInterest: '\$16.8B',
      btcDominance: '54.5%',
      atr: '\$820',
      marketStateName: 'CALM',
      r1: r'$83,200',
      now: r'$67,892',
      s1: r'$80,800',
      aiDjNote: 'Low volatility window. Ideal for deep analysis.',
      insight: 'Market calm and stable.\nPerfect for deep introspection.',
    ),
  );

  // ── 4. Deep Focus ──────────────────────────────────────────────────────────
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
      Color(0xFF004040), Color(0xFF00A898), Color(0xFF00F5E4),
    ],
    atmosphereColors: <Color>[
      Color(0xFF02080E), Color(0xFF00E2D6), Color(0xFF008878), Color(0xFF001420),
    ],
    analytics: AnalyticsData(
      bias: 'Neutral',
      volatility: 'Very Low',
      mtfAlignment: '1D ↑  4H ↑  1H →',
      aiMarketMood: 'Calm',
      fearGreedMini: '66',
      fearGreedLabel: 'Greed',
      funding: '+0.008%',
      openInterest: '\$17.2B',
      btcDominance: '54.0%',
      atr: '\$680',
      marketStateName: 'CALM',
      r1: r'$68,300',
      now: r'$67,892',
      s1: r'$67,500',
      aiDjNote: 'Clean structure. Key zones holding. Stay focused.',
      insight: 'Structure intact. Key levels holding.\nFocus. Execute. Stay calm.',
    ),
  );

  // ── 5. Recovery Mode ───────────────────────────────────────────────────────
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
      Color(0xFF044830), Color(0xFF0EC876), Color(0xFF60F5B0),
    ],
    atmosphereColors: <Color>[
      Color(0xFF020805), Color(0xFF18E895), Color(0xFF068A5C), Color(0xFF01180E),
    ],
    analytics: AnalyticsData(
      bias: 'Bearish',
      volatility: 'High',
      mtfAlignment: '1D →  4H ↓  1H →',
      aiMarketMood: 'Cautious',
      fearGreedMini: '61',
      fearGreedLabel: 'Neutral',
      funding: '-0.004%',
      openInterest: '\$14.6B',
      btcDominance: '55.1%',
      atr: '\$1,540',
      marketStateName: 'RECOVERY',
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
