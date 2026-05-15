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
import 'widgets/signal_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage — Signal FM main screen
// Dart compatibility: Dart 2.17+, no records, no abstract final class.
//
// Layout order:
//   ① Session selector pill + LIVE badge
//   ② BTC strip with inline F&G mini
//   ③ Album artwork + track info + waveform + controls
//   ④ Live Analytics card
//   ⑤ Price Map card
//   ⑥ Quick Modes row
//   ⑦ AI DJ bar + Bottom navigation
//
// On all screen sizes: content centered, max-width 480px.
// ─────────────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SessionMode _mode = SignalFmSessions.tokyoNight;
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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
      builder: (BuildContext context, Color? bg, Widget? child) {
        return Stack(
          children: <Widget>[
            // Deep background fill
            Positioned.fill(
              child: ColoredBox(
                color: bg ?? _mode.backgroundColor,
              ),
            ),
            // Living atmosphere orbs
            Positioned.fill(
              child: AtmosphereLayer(
                mode: _mode,
                marketState: _marketState,
              ),
            ),
            // App scaffold (transparent bg — atmosphere shows through)
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
                  builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxWidth: 480),
                        child: _PlayerColumn(
                          mode: _mode,
                          marketState: _marketState,
                          onModeChanged: _onModeChanged,
                          onBtcLongPress: _cycleMarketState,
                          isWide: constraints.maxWidth >=
                              AppBreakpoints.mobile,
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
// _PlayerColumn
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
        children: <Widget>[
          _SessionSelectorBar(mode: mode, onModeChanged: onModeChanged),
          const SizedBox(height: 10),
          GestureDetector(
            onLongPress: onBtcLongPress,
            child: BtcStrip(mode: mode),
          ),
          const SizedBox(height: 14),
          AlbumPlayerCard(mode: mode, marketState: marketState),
          const SizedBox(height: 14),
          LiveAnalyticsStrip(mode: mode),
          const SizedBox(height: 14),
          QuickModesRow(activeMode: mode, onModeChanged: onModeChanged),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SessionSelectorBar
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
      children: <Widget>[
        GestureDetector(
          onTap: () => _showSessionPicker(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.13),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(mode.quickModeIcon,
                    size: 13, color: mode.primaryColor),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    mode.displayName,
                    key: ValueKey<String>(mode.id),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF5F6FA),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 14,
                  color: Color(0xFF6B82A0),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        _LiveBadge(mode: mode),
      ],
    );
  }

  void _showSessionPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => _SessionPickerSheet(
        mode: mode,
        onModeChanged: onModeChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LiveBadge
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
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (BuildContext context, Widget? child) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.mode.primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.mode.primaryColor.withOpacity(0.30),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.diamond_outlined,
                size: 10,
                color: widget.mode.primaryColor
                    .withOpacity(_pulse.value),
              ),
              const SizedBox(width: 4),
              Text(
                'LIVE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: widget.mode.primaryColor
                      .withOpacity(_pulse.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SessionPickerSheet
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
        border: Border.all(
          color: Colors.white.withOpacity(0.13),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF6B82A0).withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Select Session',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFF5F6FA),
            ),
          ),
          const SizedBox(height: 12),
          ...SignalFmSessions.all.map(
            (SessionMode session) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: session.primaryColor.withOpacity(0.15),
                ),
                child: Icon(
                  session.quickModeIcon,
                  size: 16,
                  color: session.primaryColor,
                ),
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
                      : const Color(0xFFF5F6FA),
                ),
              ),
              subtitle: Text(
                session.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B82A0),
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
// _BottomArea — AI DJ bar + bottom nav
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
          top: BorderSide(
            color: Colors.white.withOpacity(0.13),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AiDjBar(mode: mode, marketState: marketState),
          BottomNavigationBar(
            currentIndex: navIndex,
            onTap: onNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: mode.primaryColor,
            unselectedItemColor: const Color(0xFF6B82A0),
            selectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            items: <BottomNavigationBarItem>[
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
                      colors: <Color>[
                        mode.primaryColor,
                        mode.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: mode.primaryColor.withOpacity(0.40),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
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
