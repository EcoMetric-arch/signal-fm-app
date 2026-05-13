import 'package:flutter/material.dart';

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

  /// Per-session waveform bar colors — 3 stops used to paint a gradient across bars.
  /// Index 0 = low bars, 1 = mid bars, 2 = peak bars.
  final List<Color> waveformColors;

  // ── Adaptive helpers ──────────────────────────────────────────────────────

  bool get isNegativeDelta => btcDelta.startsWith('-');

  /// High-contrast primary text.
  Color get onBackground =>
      isDark ? const Color(0xFFF0F2F5) : const Color(0xFF0F1623);

  /// Secondary / muted text — minimum 4.5:1 contrast on all session backgrounds.
  Color get onBackgroundMuted =>
      isDark ? const Color(0xFF8FA3B8) : const Color(0xFF556070);

  /// Translucent card surface.
  Color get surfaceColor => isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.white.withOpacity(0.68);

  /// Card border.
  Color get surfaceBorder => isDark
      ? Colors.white.withOpacity(0.09)
      : Colors.white.withOpacity(0.85);

  /// Soft glow color for accent shadows (primaryColor at low opacity).
  Color get accentGlow => primaryColor.withOpacity(0.22);
}

// ─────────────────────────────────────────────────────────────────────────────
// SignalFmSessions
// ─────────────────────────────────────────────────────────────────────────────

class SignalFmSessions {
  // ── 1. London Open ─────────────────────────────────────────────────────────
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
    waveformColors: [
      Color(0xFFFFD58E),
      Color(0xFFFFB84D),
      Color(0xFFE8973A),
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

  // ── 2. NY Momentum ─────────────────────────────────────────────────────────
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
    waveformColors: [
      Color(0xFF004E8C),
      Color(0xFF0080D0),
      Color(0xFF00C2FF),
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

  // ── 3. Tokyo Night ─────────────────────────────────────────────────────────
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
    waveformColors: [
      Color(0xFF4A1A80),
      Color(0xFF8B40D4),
      Color(0xFFCB9CFF),
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

  // ── 4. Deep Focus ──────────────────────────────────────────────────────────
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
    waveformColors: [
      Color(0xFF005C54),
      Color(0xFF00B8A0),
      Color(0xFF00FFE5),
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

  // ── 5. Recovery Mode ───────────────────────────────────────────────────────
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
    waveformColors: [
      Color(0xFF6B1515),
      Color(0xFFCC3333),
      Color(0xFFFF8A8A),
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
    londonOpen,
    nyMomentum,
    tokyoNight,
    deepFocus,
    recoveryMode,
  ];

  static SessionMode fromId(String id) => all.firstWhere(
        (s) => s.id == id,
        orElse: () => londonOpen,
      );
}