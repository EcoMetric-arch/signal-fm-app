import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/theme/signal_fm_theme.dart';
import '../../shared/widgets/app_breakpoints.dart';
import 'widgets/ai_dj_bar.dart';
import 'widgets/album_player_card.dart';
import 'widgets/atmosphere_painter.dart';
import 'widgets/btc_strip.dart';
import 'widgets/live_analytics_strip.dart';
import 'widgets/quick_modes_row.dart';
import 'widgets/session_modes_panel.dart';
import 'widgets/signal_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage  (Phase 6)
//
// Layout matches the reference image precisely:
//
//   ① Session selector (top bar)
//   ② BTC ticker strip + Fear & Greed mini (inline)
//   ③ Hero player (artwork ring + track info + waveform + controls)
//   ④ Live Analytics card (TraderaEdge + insight + F&G gauge)
//   ⑤ Price Map card
//   ⑥ Quick Modes row
//   ⑦ AI DJ bar + Bottom nav
//
// On wide screens (≥ AppBreakpoints.mobile): same layout is centered in a
// max-width container so it never stretches into a dashboard.
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SessionMode _mode = SignalFmSessions.tokyoNight; // default matches reference
  SessionMode _prevMode = SignalFmSessions.tokyoNight;
  int _navIndex = 0;
  int _marketStateIndex = 1; // bullish by default

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

  void _cycleMarketState() {
    HapticFeedback.lightImpact();
    setState(() => _marketStateIndex++);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
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
            // Living atmosphere background
            Positioned.fill(
              child: ColoredBox(color: bg ?? _mode.backgroundColor),
            ),
            Positioned.fill(
              child: AtmosphereLayer(
                mode: _mode,
                marketState: _marketState,
              ),
            ),

            // App scaffold
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
                    // On all screen widths: centered column with max width 480
                    // This preserves phone proportions on tablet/desktop.
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _PlayerColumn(
                          mode: _mode,
                          marketState: _marketState,
                          onModeChanged: _onModeChanged,
                          onBtcLongPress: _cycleMarketState,
                          isWide: constraints.maxWidth >= AppBreakpoints.mobile,
                        ),
                      ),
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
// _PlayerColumn — single scrollable column matching the reference layout
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerColumn extends StatelessWidget {
  const _PlayerColumn({
    required this.mode,
    required this.marketState,
    required this.onModeChanged,
    required this.onBtcLongPress,
    required this.isWide,
  });

  final SessionMode mode;
  final MarketStateData marketState;
  final ValueChanged<SessionMode> onModeChanged;
  final VoidCallback onBtcLongPress;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ① Session selector bar
          _SessionSelectorBar(mode: mode, onModeChanged: onModeChanged),

          const SizedBox(height: 10),

          // ② BTC strip (with F&G mini inline on right)
          GestureDetector(
            onLongPress: onBtcLongPress,
            child: BtcStrip(mode: mode),
          ),

          const SizedBox(height: 14),

          // ③ Hero player
          AlbumPlayerCard(mode: mode, marketState: marketState),

          const SizedBox(height: 14),

          // ④⑤ Live Analytics + Price Map
          LiveAnalyticsStrip(mode: mode),

          const SizedBox(height: 14),

          // ⑥ Quick Modes
          QuickModesRow(activeMode: mode, onModeChanged: onModeChanged),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SessionSelectorBar — reference item ①
// Compact dropdown-style pill showing active session + LIVE badge
// ─────────────────────────────────────────────────────────────────────────────

class _SessionSelectorBar extends StatelessWidget {
  const _SessionSelectorBar({
    required this.mode,
    required this.onModeChanged,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Session pill — tap to show bottom sheet selector
        GestureDetector(
          onTap: () => _showSessionPicker(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: mode.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mode.surfaceBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(mode.quickModeIcon,
                    size: 13, color: mode.primaryColor),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    mode.displayName,
                    key: ValueKey(mode.id),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mode.onBackground,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 14, color: mode.onBackgroundMuted),
              ],
            ),
          ),
        ),

        const Spacer(),

        // LIVE badge
        _LiveBadge(mode: mode),
      ],
    );
  }

  void _showSessionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionPickerSheet(
        mode: mode,
        onModeChanged: onModeChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LiveBadge — pulsing diamond + LIVE text
// ─────────────────────────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  const _LiveBadge({required this.mode});
  final SessionMode mode;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
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
    _pulse = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.mode.primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.mode.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.diamond_outlined,
              size: 10,
              color: widget.mode.primaryColor.withOpacity(_pulse.value),
            ),
            const SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: widget.mode.primaryColor.withOpacity(_pulse.value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SessionPickerSheet — bottom sheet session selector
// ─────────────────────────────────────────────────────────────────────────────

class _SessionPickerSheet extends StatelessWidget {
  const _SessionPickerSheet({
    required this.mode,
    required this.onModeChanged,
  });

  final SessionMode mode;
  final ValueChanged<SessionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Color.lerp(mode.backgroundColor, Colors.white, 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mode.surfaceBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: mode.onBackgroundMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Select Session',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: mode.onBackground,
            ),
          ),
          const SizedBox(height: 12),
          ...SignalFmSessions.all.map(
            (session) => ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: session.primaryColor.withOpacity(0.15),
                ),
                child: Icon(session.quickModeIcon,
                    size: 16, color: session.primaryColor),
              ),
              title: Text(
                session.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: session.id == mode.id
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: session.id == mode.id
                      ? mode.primaryColor
                      : mode.onBackground,
                ),
              ),
              subtitle: Text(
                session.subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: mode.onBackgroundMuted,
                ),
              ),
              trailing: session.id == mode.id
                  ? Icon(Icons.check_rounded,
                      size: 16, color: mode.primaryColor)
                  : null,
              onTap: () {
                onModeChanged(session);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomArea — AI DJ bar + bottom navigation
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
    final Color barBg =
        Color.lerp(mode.backgroundColor, Colors.white, 0.05)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(color: mode.surfaceBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AiDjBar(mode: mode, marketState: marketState),
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
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore_rounded),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [mode.primaryColor, mode.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mode.primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                label: 'Player',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome_rounded),
                label: 'AI DJ',
              ),
              const BottomNavigationBarItem(
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
