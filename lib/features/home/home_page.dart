import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/theme/signal_fm_theme.dart';
import '../../shared/widgets/app_breakpoints.dart';
import 'widgets/ai_dj_bar.dart';
import 'widgets/album_player_card.dart';
import 'widgets/atmosphere_painter.dart';
import 'widgets/btc_strip.dart';
import 'widgets/live_analytics_strip.dart';
import 'widgets/market_feed_strip.dart';
import 'widgets/quick_modes_row.dart';
import 'widgets/signal_header.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage — Phase 7
//
// Layout (top → bottom):
//   MarketFeedStrip      ← live instrument ticker (new)
//   _TopBar              ← ADAPTIVE MODE pill (primary) + session override pill
//   BtcStrip             ← BTC price + F&G inline
//   AlbumPlayerCard      ← artwork + waveform + controls
//   LiveAnalyticsStrip   ← 7-field cockpit + price map (now receives marketState)
//   QuickModesRow        ← secondary / manual override label
//   AiDjBar + BottomNav
//
// Dart 2.17+, no abstract final class, no records.
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
  int _marketStateIndex = 1; // bullish default

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
            Positioned.fill(
              child: ColoredBox(color: bg ?? _mode.backgroundColor),
            ),
            Positioned.fill(
              child: AtmosphereLayer(
                mode: _mode,
                marketState: _marketState,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              bottomNavigationBar: _BottomArea(
                mode: _mode,
                marketState: _marketState,
                navIndex: _navIndex,
                onNavTap: _onNavTap,
              ),
              body: Column(
                children: <Widget>[
                  // Live feed ticker — always at very top, above SafeArea padding
                  SafeArea(
                    bottom: false,
                    child: MarketFeedStrip(mode: _mode),
                  ),
                  // Scrollable player column
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints bc) {
                        return Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 480),
                            child: _PlayerColumn(
                              mode: _mode,
                              marketState: _marketState,
                              onModeChanged: _onModeChanged,
                              onMarketStateTap: _cycleMarketState,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
    required this.onMarketStateTap,
  });

  final SessionMode mode;
  final MarketStateData marketState;
  final ValueChanged<SessionMode> onModeChanged;
  final VoidCallback onMarketStateTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ① Adaptive mode bar (primary) + session override
          _TopBar(
            mode: mode,
            marketState: marketState,
            onModeChanged: onModeChanged,
            onMarketStateTap: onMarketStateTap,
          ),
          const SizedBox(height: 10),

          // ② BTC strip
          BtcStrip(mode: mode),
          const SizedBox(height: 12),

          // ③ Hero player
          AlbumPlayerCard(mode: mode, marketState: marketState),
          const SizedBox(height: 12),

          // ④ Market intelligence cockpit
          LiveAnalyticsStrip(mode: mode, marketState: marketState),
          const SizedBox(height: 12),

          // ⑤ Quick modes — secondary / manual override
          QuickModesRow(activeMode: mode, onModeChanged: onModeChanged),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TopBar
//
// Left:  ADAPTIVE MODE pill — primary product concept
// Right: session override pill (secondary) + LIVE badge
//
// Hierarchy: Adaptive Mode is the product. Session selector is manual override.
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.mode,
    required this.marketState,
    required this.onModeChanged,
    required this.onMarketStateTap,
  });

  final SessionMode mode;
  final MarketStateData marketState;
  final ValueChanged<SessionMode> onModeChanged;
  final VoidCallback onMarketStateTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // ── ADAPTIVE MODE — primary pill ─────────────────────────────
        _AdaptiveModePill(mode: mode, marketState: marketState),

        const SizedBox(width: 8),

        // ── Session override — secondary, smaller ────────────────────
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(mode.quickModeIcon,
                    size: 11, color: mode.onBackgroundMuted),
                const SizedBox(width: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    mode.displayName,
                    key: ValueKey<String>(mode.id),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: mode.onBackgroundMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 12, color: mode.onBackgroundMuted),
              ],
            ),
          ),
        ),

        const Spacer(),

        // ── LIVE badge ───────────────────────────────────────────────
        _LiveBadge(mode: mode),
      ],
    );
  }

  void _showPicker(BuildContext context) {
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
// _AdaptiveModePill — the primary system indicator
// Tapping cycles market state (demo). Phase 8: driven by AI engine.
// ─────────────────────────────────────────────────────────────────────────────

class _AdaptiveModePill extends StatefulWidget {
  const _AdaptiveModePill({required this.mode, required this.marketState});

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  State<_AdaptiveModePill> createState() => _AdaptiveModePillState();
}

class _AdaptiveModePillState extends State<_AdaptiveModePill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
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
    final SessionMode mode = widget.mode;
    final MarketStateData ms = widget.marketState;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            // Stronger visual weight than session override pill
            color: mode.primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: mode.primaryColor
                  .withOpacity(0.30 + _pulse.value * 0.12),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: mode.primaryColor
                    .withOpacity(0.12 + _pulse.value * 0.08),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Pulsing dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mode.primaryColor.withOpacity(_pulse.value),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'ADAPTIVE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFFF5F6FA),
                ),
              ),
              const SizedBox(width: 6),
              // State chip inline
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: ms.stateColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  ms.label,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: ms.stateColor,
                  ),
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
              const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: widget.mode.primaryColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.mode.primaryColor.withOpacity(0.26),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.diamond_outlined,
                size: 9,
                color: widget.mode.primaryColor.withOpacity(_pulse.value),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
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
          const SizedBox(height: 12),
          Row(
            children: const <Widget>[
              Text(
                'Manual Override',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF5F6FA),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '— Adaptive Mode will resume',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B82A0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...SignalFmSessions.all.map((SessionMode session) {
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: session.primaryColor.withOpacity(0.14),
                ),
                child: Icon(session.quickModeIcon,
                    size: 15, color: session.primaryColor),
              ),
              title: Text(
                session.displayName,
                style: TextStyle(
                  fontSize: 13,
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
                    fontSize: 10, color: Color(0xFF6B82A0)),
              ),
              trailing: session.id == mode.id
                  ? Icon(Icons.check_rounded,
                      size: 14, color: mode.primaryColor)
                  : null,
              onTap: () {
                onModeChanged(session);
                Navigator.of(context).pop();
              },
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomArea — AiDjBar + BottomNav
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
            color: Colors.white.withOpacity(0.10),
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
                  width: 42,
                  height: 42,
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
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 19,
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
