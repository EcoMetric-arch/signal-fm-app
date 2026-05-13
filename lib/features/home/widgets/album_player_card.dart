import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';
import 'live_analytics_strip.dart';
import 'waveform_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AlbumPlayerCard
//
// RULE: this widget NEVER returns Expanded at its root.
// The parent (_WideLayout) is responsible for wrapping it in Expanded(flex:2).
// Internally, content is always a scrollable Column — no Expanded child
// of a Row/Column can appear at the widget's own root level.
//
// Layout strategy (both paths)
// ─────────────────────────────
//   AnimatedContainer            ← card shell
//     └─ SingleChildScrollView   ← prevents overflow on small screens
//          └─ Column (min)       ← intrinsic height always
//               └─ [content]
//
// Art is a fixed pixel circle (180 px mobile, 200 px wide).
// No Expanded, no AspectRatio — both require a bounded parent height which
// SingleChildScrollView cannot provide.
// ─────────────────────────────────────────────────────────────────────────────

class AlbumPlayerCard extends StatelessWidget {
  const AlbumPlayerCard({
    required this.mode,
    this.scrollable = false,
    super.key,
  });

  final SessionMode mode;

  /// [scrollable] = true  → mobile (intrinsic height, 180 px art).
  /// [scrollable] = false → wide   (fills Expanded parent, 200 px art).
  /// Either way this widget itself never returns Expanded.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final double artSize = scrollable ? 180.0 : 200.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      // On the wide path the parent Expanded(flex:2) provides height;
      // setting height:infinity makes the card fill it.
      // On mobile the ScrollView parent sizes us intrinsically.
      height: scrollable ? null : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: mode.surfaceColor,
        border: Border.all(color: mode.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: mode.accentGlow,
            blurRadius: 42,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Album art (fixed size — no Expanded / AspectRatio) ────────
            _AlbumArt(mode: mode, size: artSize),

            const SizedBox(height: 18),

            // ── Session title ─────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.15),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                mode.title,
                key: ValueKey(mode.id),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: mode.onBackground,
                  letterSpacing: 0.2,
                  height: 1.1,
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Session subtitle ──────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Text(
                mode.subtitle,
                key: ValueKey('${mode.id}_sub'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mode.onBackgroundMuted,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Waveform ──────────────────────────────────────────────────
            SizedBox(
              height: 60,
              child: WaveformDisplay(
                accentColor: mode.primaryColor,
                waveformColors: mode.waveformColors,
              ),
            ),

            const SizedBox(height: 16),

            // ── Player controls ───────────────────────────────────────────
            _PlayerControls(mode: mode),

            const SizedBox(height: 18),

            // ── Live analytics ────────────────────────────────────────────
            LiveAnalyticsStrip(mode: mode),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AlbumArt — fixed pixel circle, no Expanded, no AspectRatio
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.mode, required this.size});

  final SessionMode mode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [mode.primaryColor, mode.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: mode.primaryColor.withOpacity(0.35),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/album_art.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlayerControls
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerControls extends StatelessWidget {
  const _PlayerControls({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GhostButton(
          icon: Icons.skip_previous_rounded,
          color: mode.onBackgroundMuted,
          size: 32,
          onTap: () {},
        ),

        const SizedBox(width: 24),

        GestureDetector(
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [mode.primaryColor, mode.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: mode.primaryColor.withOpacity(0.45),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.pause_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),

        const SizedBox(width: 24),

        _GhostButton(
          icon: Icons.skip_next_rounded,
          color: mode.onBackgroundMuted,
          size: 32,
          onTap: () {},
        ),
      ],
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: color),
    );
  }
}