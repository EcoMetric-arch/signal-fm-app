import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/theme/signal_fm_theme.dart';
import '../../shared/widgets/app_breakpoints.dart';
import 'widgets/album_player_card.dart';
import 'widgets/btc_strip.dart';
import 'widgets/fear_greed_panel.dart';
import 'widgets/quick_modes_row.dart';
import 'widgets/session_modes_panel.dart';
import 'widgets/signal_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage  (Phase 3)
//
// Responsive strategy (via LayoutBuilder at the body level):
//   < 600 px  — _MobileLayout  : single scrollable column, compact header
//   ≥ 600 px  — _WideLayout    : two-panel row (player left, market right)
//
// Session transitions:
//   • Background: TweenAnimationBuilder interpolates between two Colors so
//     the entire background cross-fades smoothly (AnimatedContainer can't
//     animate between arbitrary Colors reliably on all Flutter versions).
//   • All child cards use their own AnimatedContainer / AnimatedSwitcher.
//   • System chrome brightness flips per session.
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SessionMode _mode = SignalFmSessions.londonOpen;
  SessionMode _prevMode = SignalFmSessions.londonOpen;
  int _navIndex = 0;

  void _onModeChanged(SessionMode next) {
    if (next.id == _mode.id) return;
    HapticFeedback.selectionClick();
    setState(() {
      _prevMode = _mode;
      _mode = next;
    });
  }

  void _onNavTap(int i) => setState(() => _navIndex = i);

  @override
  Widget build(BuildContext context) {
    // System status bar contrast
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness:
          _mode.isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          _mode.isDark ? Brightness.dark : Brightness.light,
    ));

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: _prevMode.backgroundColor,
        end: _mode.backgroundColor,
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, bg, _) {
        return Scaffold(
          backgroundColor: bg ?? _mode.backgroundColor,
          bottomNavigationBar: _SignalBottomNav(
            currentIndex: _navIndex,
            mode: _mode,
            onTap: _onNavTap,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < AppBreakpoints.mobile) {
                  return _MobileLayout(
                    mode: _mode,
                    onModeChanged: _onModeChanged,
                  );
                }
                return _WideLayout(
                  mode: _mode,
                  onModeChanged: _onModeChanged,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MobileLayout  (<600 px)
//
// Single scrollable column. Player card is in scrollable=true mode so it
// renders as intrinsic height — no Expanded, no overflow.
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.mode,
    required this.onModeChanged,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header (hides tagline)
          SignalHeader(mode: mode, compact: true),

          const SizedBox(height: 12),

          BtcStrip(mode: mode),

          const SizedBox(height: 10),

          // Quick modes — horizontal scroll
          QuickModesRow(activeMode: mode, onModeChanged: onModeChanged),

          const SizedBox(height: 14),

          // Player card — intrinsic height, no Expanded
          AlbumPlayerCard(mode: mode, scrollable: true),

          const SizedBox(height: 14),

          // Fear & Greed
          FearGreedPanel(mode: mode),

          const SizedBox(height: 14),

          // Session modes — intrinsic height on mobile (no Expanded)
          _MobileSessionPanel(mode: mode, onModeChanged: onModeChanged),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MobileSessionPanel — session buttons without Expanded (intrinsic height)
// ─────────────────────────────────────────────────────────────────────────────

class _MobileSessionPanel extends StatelessWidget {
  const _MobileSessionPanel({
    required this.mode,
    required this.onModeChanged,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: mode.surfaceColor,
        border: Border.all(color: mode.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SESSION MODES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: mode.onBackgroundMuted,
            ),
          ),
          const SizedBox(height: 10),
          ...SignalFmSessions.all.map(
            (session) => _MobileModeButton(
              session: session,
              isActive: session.id == mode.id,
              activeMode: mode,
              onTap: () => onModeChanged(session),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileModeButton extends StatelessWidget {
  const _MobileModeButton({
    required this.session,
    required this.isActive,
    required this.activeMode,
    required this.onTap,
  });

  final SessionMode session;
  final bool isActive;
  final SessionMode activeMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = activeMode.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isActive ? accent.withOpacity(0.13) : Colors.transparent,
          border: Border.all(
            color: isActive ? accent.withOpacity(0.50) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              session.quickModeIcon,
              size: 15,
              color: isActive ? accent : activeMode.onBackgroundMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                session.displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? activeMode.onBackground
                      : activeMode.onBackgroundMuted,
                ),
              ),
            ),
            if (isActive)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WideLayout  (≥600 px — tablet & desktop)
//
// Two-panel row. Player on the left (flex 2), market/session on the right.
// Constrain max width on desktop so the layout doesn't stretch absurdly.
// ─────────────────────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.mode,
    required this.onModeChanged,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          SignalHeader(mode: mode),

          const SizedBox(height: 12),

          // ── BTC strip ────────────────────────────────────────────────
          BtcStrip(mode: mode),

          const SizedBox(height: 10),

          // ── Quick modes ──────────────────────────────────────────────
          QuickModesRow(activeMode: mode, onModeChanged: onModeChanged),

          const SizedBox(height: 14),

          // ── Main two-panel row ───────────────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left — player (flex 2)
                Expanded(
                  flex: 2,
                  child: AlbumPlayerCard(mode: mode),
                ),

                const SizedBox(width: 16),

                // Right — market data + session selector
                Expanded(
                  child: Column(
                    children: [
                      FearGreedPanel(mode: mode),

                      const SizedBox(height: 12),

                      Expanded(
                        child: SessionModesPanel(
                          activeMode: mode,
                          onModeChanged: onModeChanged,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SignalBottomNav
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
    final Color barBg = mode.isDark
        ? Color.lerp(mode.backgroundColor, Colors.white, 0.05)!
        : Color.lerp(mode.backgroundColor, Colors.white, 0.55)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(color: mode.surfaceBorder, width: 1),
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
          letterSpacing: 0.2,
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