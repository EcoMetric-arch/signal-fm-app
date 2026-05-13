import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketState — emotional state modifier that layers on top of SessionMode.
//
// Each state carries multipliers used by the atmosphere / waveform system:
//   glowScale      — how intense the glow effects are (1.0 = normal)
//   animSpeedScale — waveform animation speed multiplier (1.0 = normal)
//   peakScale      — how exaggerated the waveform peak heights are
//   shadowScale    — depth of card shadows
//   aiDjMessage    — the ambient AI DJ readout for this state
// ─────────────────────────────────────────────────────────────────────────────

enum MarketState {
  calm,
  bullish,
  breakout,
  panic,
  recovery,
  riskOff,
}

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

  /// 0.5–2.0. Multiplied against session accentGlow opacity.
  final double glowScale;

  /// 0.5–2.0. Multiplied against waveform animation duration.
  final double animSpeedScale;

  /// 0.6–1.4. Scales maximum waveform bar height.
  final double peakScale;

  /// 0.5–1.8. Scales card box-shadow spread.
  final double shadowScale;

  /// 0.5–1.5. How much bars breathe (idle oscillation amplitude).
  final double breatheScale;

  /// The ambient AI DJ message shown when this state is active.
  final String aiDjMessage;
}

class SignalFmSessions {
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
// AnalyticsData
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsData {
  const AnalyticsData({
    required this.bias,
    required this.volatility,
    required this.mtfAlignment,
    required this.aiMarketMood,
    required this.fearGreedMini,
    required this.r1,
    required this.now,
    required this.s1,
    required this.aiDjNote,
  });

  final String bias;
  final String volatility;
  final String mtfAlignment;
  final String aiMarketMood;
  final String fearGreedMini;
  final String r1;
  final String now;
  final String s1;
  final String aiDjNote;
}

// ─────────────────────────────────────────────────────────────────────────────
// SessionMode
// ─────────────────────────────────────────────────────────────────────────────

class SessionMode {
  const SessionMode({
    required this.id,
    required this.displayName,
    required this.title,
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

  /// 4 colors used by the ambient atmosphere painter:
  ///   [0] deep base, [1] mid orb, [2] accent bloom, [3] rim/edge
  final List<Color> atmosphereColors;

  // ── Adaptive helpers ──────────────────────────────────────────────────────

  bool get isNegativeDelta => btcDelta.startsWith('-');

  Color get onBackground =>
      isDark ? const Color(0xFFF0F2F5) : const Color(0xFF0F1623);

  Color get onBackgroundMuted =>
      isDark ? const Color(0xFF8FA3B8) : const Color(0xFF556070);

  Color get surfaceColor => isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.white.withOpacity(0.68);

  Color get surfaceBorder => isDark
      ? Colors.white.withOpacity(0.09)
      : Colors.white.withOpacity(0.85);

  Color get accentGlow => primaryColor.withOpacity(0.22);
}

// ─────────────────────────────────────────────────────────────────────────────
// SignalFmSessions
// ─────────────────────────────────────────────────────────────────────────────

class SignalFmSessions {
  // ── 1. London Open — warm sunrise energy ──────────────────────────────────
  static const SessionMode londonOpen = SessionMode(
    id: 'London Open',
    displayName: 'London Open',
    title: 'London Focus',
    subtitle: 'Clarity. Focus. Precision.',
    mood: 'Focused',
    btcDelta: '+1.32%',
    fearIndex: '64',
    backgroundColor: Color(0xFFEDF1F7),
    primaryColor: Color(0xFFFFB84D),
    secondaryColor: Color(0xFF4A90E2),
    quickModeIcon: Icons.wb_sunny_outlined,
    isDark: false,
    waveformColors: [Color(0xFFFFD58E), Color(0xFFFFB84D), Color(0xFFE8973A)],
    atmosphereColors: [
      Color(0xFFE8DCC8), // warm parchment base
      Color(0xFFFFD077), // golden mid bloom
      Color(0xFFB8D4F0), // cool blue accent
      Color(0xFFF5E8D0), // sunrise rim
    ],
    analytics: AnalyticsData(
      bias: 'Bullish',
      volatility: 'Medium',
      mtfAlignment: 'Aligned ↑',
      aiMarketMood: 'Risk-On',
      fearGreedMini: '64',
      r1: r'\$68,400',
      now: r'\$67,892',
      s1: r'\$66,100',
      aiDjNote: 'Momentum building in BTC. Focus mode recommended.',
    ),
  );

  // ── 2. NY Momentum — electric blue momentum ────────────────────────────────
  static const SessionMode nyMomentum = SessionMode(
    id: 'NY Momentum',
    displayName: 'NY Momentum',
    title: 'NY Momentum',
    subtitle: 'Energy. Volatility. Movement.',
    mood: 'High Momentum',
    btcDelta: '+2.48%',
    fearIndex: '72',
    backgroundColor: Color(0xFF07111F),
    primaryColor: Color(0xFF00A3FF),
    secondaryColor: Color(0xFF0057FF),
    quickModeIcon: Icons.bolt_outlined,
    isDark: true,
    waveformColors: [Color(0xFF004E8C), Color(0xFF0080D0), Color(0xFF00C2FF)],
    atmosphereColors: [
      Color(0xFF020810), // deep navy base
      Color(0xFF003A7A), // electric mid
      Color(0xFF005BBF), // blue bloom
      Color(0xFF001A3D), // midnight rim
    ],
    analytics: AnalyticsData(
      bias: 'Strong Bull',
      volatility: 'High',
      mtfAlignment: 'Aligned ↑',
      aiMarketMood: 'Euphoric',
      fearGreedMini: '72',
      r1: r'\$69,500',
      now: r'\$67,892',
      s1: r'\$66,800',
      aiDjNote: 'High-energy session. Volume surge detected. Stay sharp.',
    ),
  );

  // ── 3. Tokyo Night — calm neon drift ──────────────────────────────────────
  static const SessionMode tokyoNight = SessionMode(
    id: 'Tokyo Night',
    displayName: 'Tokyo Night',
    title: 'Tokyo Night',
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
      Color(0xFF080414), // deep violet base
      Color(0xFF2A0A50), // purple mid bloom
      Color(0xFF1A0840), // indigo accent
      Color(0xFF0C0520), // dark rim
    ],
    analytics: AnalyticsData(
      bias: 'Neutral',
      volatility: 'Low',
      mtfAlignment: 'Mixed',
      aiMarketMood: 'Cautious',
      fearGreedMini: '58',
      r1: r'\$68,100',
      now: r'\$67,892',
      s1: r'\$67,200',
      aiDjNote: 'Low volatility window. Ideal for deep analysis.',
    ),
  );

  // ── 4. Deep Focus — tunnel vision teal ────────────────────────────────────
  static const SessionMode deepFocus = SessionMode(
    id: 'Deep Focus',
    displayName: 'Deep Focus',
    title: 'Deep Focus',
    subtitle: 'Signal only. No noise.',
    mood: 'Focused',
    btcDelta: '+0.18%',
    fearIndex: '61',
    backgroundColor: Color(0xFF080D18),
    primaryColor: Color(0xFF00E5CC),
    secondaryColor: Color(0xFF007A6E),
    quickModeIcon: Icons.track_changes_outlined,
    isDark: true,
    waveformColors: [Color(0xFF005C54), Color(0xFF00B8A0), Color(0xFF00FFE5)],
    atmosphereColors: [
      Color(0xFF040810), // near-black base
      Color(0xFF003830), // deep teal mid
      Color(0xFF005548), // focused bloom
      Color(0xFF020608), // void rim
    ],
    analytics: AnalyticsData(
      bias: 'Neutral',
      volatility: 'Very Low',
      mtfAlignment: 'Aligned ↑',
      aiMarketMood: 'Calm',
      fearGreedMini: '61',
      r1: r'\$68,250',
      now: r'\$67,892',
      s1: r'\$67,500',
      aiDjNote: 'Clean structure. Key zones holding. Stay focused.',
    ),
  );

  // ── 5. Recovery Mode — soft healing atmosphere ─────────────────────────────
  static const SessionMode recoveryMode = SessionMode(
    id: 'Recovery Mode',
    displayName: 'Recovery Mode',
    title: 'Recovery',
    subtitle: 'Breathe. Reset. Rebuild.',
    mood: 'Recovering',
    btcDelta: '-1.20%',
    fearIndex: '38',
    backgroundColor: Color(0xFF160A0A),
    primaryColor: Color(0xFFFF6B6B),
    secondaryColor: Color(0xFF8B0000),
    quickModeIcon: Icons.self_improvement_outlined,
    isDark: true,
    waveformColors: [Color(0xFF6B1515), Color(0xFFCC3333), Color(0xFFFF8A8A)],
    atmosphereColors: [
      Color(0xFF100505), // dark crimson base
      Color(0xFF3A0808), // deep red mid
      Color(0xFF250505), // muted bloom
      Color(0xFF0E0303), // void rim
    ],
    analytics: AnalyticsData(
      bias: 'Bearish',
      volatility: 'High',
      mtfAlignment: 'Misaligned',
      aiMarketMood: 'Fear',
      fearGreedMini: '38',
      r1: r'\$68,000',
      now: r'\$67,892',
      s1: r'\$65,400',
      aiDjNote: 'Market in recovery. Reduce risk. Let the session breathe.',
    ),
  );

  static const List<SessionMode> all = [
    londonOpen, nyMomentum, tokyoNight, deepFocus, recoveryMode,
  ];

  static SessionMode fromId(String id) => all.firstWhere(
        (s) => s.id == id,
        orElse: () => londonOpen,
      );
}
