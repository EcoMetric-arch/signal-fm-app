import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/theme/signal_fm_theme.dart';
import '../../shared/widgets/app_breakpoints.dart';
import 'widgets/ai_dj_bar.dart';
import 'widgets/album_player_card.dart';
import 'widgets/atmosphere_painter.dart';
import 'widgets/btc_strip.dart';
import 'widgets/fear_greed_panel.dart';
import 'widgets/quick_modes_row.dart';
import 'widgets/session_modes_panel.dart';
import 'widgets/signal_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage  (Phase 5)
//
// New additions:
//   • MarketStateData _marketState — cycles through states via a demo button
//     in the header area (long-press BTC strip to advance state).
//     In Phase 6 this comes from a real data provider.
//   • AtmosphereLayer — full-screen ambient background in a Stack.
//   • AiDjBar — ambient AI readout above the bottom nav.
//   • marketState passed down to AlbumPlayerCard → WaveformDisplay.
//
// Layout (unchanged from Phase 3):
//   Stack
//     AtmosphereLayer    ← living background
//     Scaffold (transparent bg)
//       body → LayoutBuilder → _MobileLayout / _WideLayout
//       bottomNavigationBar → Column(AiDjBar + _SignalBottomNav)
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

  // Market state — cycles on demo tap; Phase 6: real data
  int _marketStateIndex = 1; // start on 'bullish'
  MarketStateData get _marketState =>
      MarketStates.all[_marketStateIndex % MarketStates.all.length];

  void _onModeChanged(SessionMode next) {
    if (next.id == _mode.id) return;
    HapticFeedback.selectionClick();
    setState(() {
      _prevMode = _mode;
      _mode = next;
    });
  }

  void _onNavTap(int i) => setState(() => _navIndex = i);

  /// Advance market state — wired to BTC strip long-press for demo purposes.
  void _cycleMarketState() {
    HapticFeedback.lightImpact();
    setState(() => _marketStateIndex++);
  }

  @override
  Widget build(BuildContext context) {
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
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOut,
      builder: (context, bg, _) {
        return Stack(
          children: [
            // ── Living atmosphere background ──────────────────────────
            Positioned.fill(
              child: ColoredBox(color: bg ?? _mode.backgroundColor),
            ),
            Positioned.fill(
              child: AtmosphereLayer(
                mode: _mode,
                marketState: _marketState,
              ),
            ),

            // ── App scaffold (transparent) ────────────────────────────
            Scaffold(
              backgroundColor: Colors.transparent,
              bottomNavigationBar: _BottomArea(
                mode: _mode,
                marketState: _marketState,
                navIndex: _navIndex,
                onNavTap: _onNavTap,
              ),
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < AppBreakpoints.mobile) {
                      return _MobileLayout(
                        mode: _mode,
                        marketState: _marketState,
                        onModeChanged: _onModeChanged,
                        onBtcLongPress: _cycleMarketState,
                      );
                    }
                    return _WideLayout(
                      mode: _mode,
                      marketState: _marketState,
                      onModeChanged: _onModeChanged,
                      onBtcLongPress: _cycleMarketState,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomArea — AiDjBar + BottomNavigationBar stacked
// ─────────────────────────────────────────────────────────────────────────────

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.mode,
    required this.marketState,
    required this.navIndex,
    required this.onNavTap,
  });

  final SessionMode mode;
  final MarketStateData marketState;
  final int navIndex;
  final ValueChanged<int> onNavTap;

  @override
  Widget build(BuildContext context) {
    final Color barBg = mode.isDark
        ? Color.lerp(mode.backgroundColor, Colors.white, 0.05)!
        : Color.lerp(mode.backgroundColor, Colors.white, 0.55)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      color: barBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AI DJ ambient bar
          AiDjBar(mode: mode, marketState: marketState),

          // Divider
          Container(
            height: 1,
            color: mode.surfaceBorder,
          ),

          // Bottom nav
          BottomNavigationBar(
            currentIndex: navIndex,
            onTap: onNavTap,
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MobileLayout
// ─────────────────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.mode,
    required this.marketState,
    required this.onModeChanged,
    required this.onBtcLongPress,
  });

  final SessionMode mode;
  final MarketStateData marketState;
  final ValueChanged<SessionMode> onModeChanged;
  final VoidCallback onBtcLongPress;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignalHeader(mode: mode, compact: true),
          const SizedBox(height: 12),

          GestureDetector(
            onLongPress: onBtcLongPress,
            child: BtcStrip(mode: mode),
          ),
          const SizedBox(height: 10),

          QuickModesRow(activeMode: mode, onModeChanged: onModeChanged),
          const SizedBox(height: 14),

          AlbumPlayerCard(
            mode: mode,
            marketState: marketState,
            scrollable: true,
          ),
          const SizedBox(height: 14),

          FearGreedPanel(mode: mode),
          const SizedBox(height: 14),

          _MobileSessionPanel(mode: mode, onModeChanged: onModeChanged),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WideLayout
// ─────────────────────────────────────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.mode,
    required this.marketState,
    required this.onModeChanged,
    required this.onBtcLongPress,
  });

  final SessionMode mode;
  final MarketStateData marketState;
  final ValueChanged<SessionMode> onModeChanged;
  final VoidCallback onBtcLongPress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignalHeader(mode: mode),
          const SizedBox(height: 12),

          GestureDetector(
            onLongPress: onBtcLongPress,
            child: BtcStrip(mode: mode),
          ),
          const SizedBox(height: 10),

          QuickModesRow(activeMode: mode, onModeChanged: onModeChanged),
          const SizedBox(height: 14),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: AlbumPlayerCard(
                    mode: mode,
                    marketState: marketState,
                  ),
                ),

                const SizedBox(width: 16),

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
// _MobileSessionPanel
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
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}