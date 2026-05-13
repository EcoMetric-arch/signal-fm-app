import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/theme/signal_fm_theme.dart';
import 'widgets/album_player_card.dart';
import 'widgets/btc_strip.dart';
import 'widgets/fear_greed_panel.dart';
import 'widgets/quick_modes_row.dart';
import 'widgets/session_modes_panel.dart';
import 'widgets/signal_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage — Phase 2
//
// State: active SessionMode (one of 5), active bottom-nav tab index.
//
// Layout (top → bottom):
//   SignalHeader          — logo + adaptive mode badge
//   BtcStrip              — BTC price + delta
//   QuickModesRow         — 5 session chips (scrollable)
//   Expanded row
//     AlbumPlayerCard     — art + waveform + controls + analytics (flex 2)
//     Right column        — FearGreedPanel + SessionModesPanel (flex 1)
//   BottomNavigationBar   — Home / Explore / Player / AI DJ / Library
//
// All widgets receive [mode] and derive their text + surface colors from
// SessionMode's adaptive helpers (onBackground, surfaceColor, etc.), so
// every one of the 5 sessions is fully readable without any per-widget
// conditional logic.
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SessionMode _mode = SignalFmSessions.londonOpen;
  int _navIndex = 0;

  void _onModeChanged(SessionMode newMode) {
    HapticFeedback.selectionClick();
    setState(() => _mode = newMode);
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // Drive system UI chrome from the active session
    final brightness =
        _mode.isDark ? Brightness.light : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: brightness,
      statusBarBrightness:
          _mode.isDark ? Brightness.dark : Brightness.light,
    ));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      color: _mode.backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // ── Bottom navigation ───────────────────────────────────────────
        bottomNavigationBar: _SignalBottomNav(
          currentIndex: _navIndex,
          mode: _mode,
          onTap: _onNavTap,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────
                SignalHeader(mode: _mode),

                const SizedBox(height: 14),

                // ── BTC strip ──────────────────────────────────────────
                BtcStrip(mode: _mode),

                const SizedBox(height: 12),

                // ── Quick modes row ────────────────────────────────────
                QuickModesRow(
                  activeMode: _mode,
                  onModeChanged: _onModeChanged,
                ),

                const SizedBox(height: 14),

                // ── Main content row ───────────────────────────────────
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left — player card (art + waveform + controls + analytics)
                      Expanded(
                        flex: 2,
                        child: AlbumPlayerCard(mode: _mode),
                      ),

                      const SizedBox(width: 16),

                      // Right — Fear & Greed + session selector
                      Expanded(
                        child: Column(
                          children: [
                            FearGreedPanel(mode: _mode),

                            const SizedBox(height: 12),

                            Expanded(
                              child: SessionModesPanel(
                                activeMode: _mode,
                                onModeChanged: _onModeChanged,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SignalBottomNav
//
// 5-tab bottom nav: Home / Explore / Player / AI DJ / Library.
// Colors adapt to the active session. Uses a plain BottomNavigationBar so
// no extra packages are needed.
// ─────────────────────────────────────────────────────────────────────────────

class _SignalBottomNav extends StatelessWidget {
  const _SignalBottomNav({
    required this.currentIndex,
    required this.mode,
    required this.onTap,
  });

  final int currentIndex;
  final SessionMode mode;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // Nav bar surface: slightly more opaque than panel surfaces
    final Color barBg = mode.isDark
        ? Color.lerp(mode.backgroundColor, Colors.white, 0.06)!
        : Color.lerp(mode.backgroundColor, Colors.white, 0.60)!;

    return Container(
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(
            color: mode.surfaceBorder,
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: mode.primaryColor,
        unselectedItemColor: mode.onBackgroundMuted,
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            activeIcon: Icon(Icons.play_circle_rounded),
            label: 'Player',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome_rounded),
            label: 'AI DJ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_outlined),
            activeIcon: Icon(Icons.library_music_rounded),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}