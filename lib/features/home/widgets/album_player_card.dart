import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';
import 'live_analytics_strip.dart';
import 'waveform_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AlbumPlayerCard  (Phase 5)
//
// Changes from Phase 3:
//   • Accepts [marketState] and passes it to WaveformDisplay.
//   • Card box-shadow blurRadius / spreadRadius scale with
//     marketState.shadowScale for atmosphere intensity.
//   • Play button glow scales with marketState.glowScale.
//   • No structural layout changes — Expanded rule intact.
// ─────────────────────────────────────────────────────────────────────────────

class AlbumPlayerCard extends StatelessWidget {
  const AlbumPlayerCard({
    required this.mode,
    required this.marketState,
    this.scrollable = false,
    super.key,
  });

  final SessionMode mode;
  final MarketStateData marketState;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final double artSize = scrollable ? 180.0 : 200.0;
    final double shadowBlur = 42 * marketState.shadowScale;
    final double shadowSpread = 2 * marketState.shadowScale;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      height: scrollable ? null : double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: mode.surfaceColor,
        border: Border.all(color: mode.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: mode.accentGlow,
            blurRadius: shadowBlur,
            spreadRadius: shadowSpread,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AlbumArt(mode: mode, size: artSize),

            const SizedBox(height: 18),

            // Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOut)),
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

            // Subtitle
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

            // Waveform — now receives marketState
            SizedBox(
              height: 60,
              child: WaveformDisplay(
                accentColor: mode.primaryColor,
                waveformColors: mode.waveformColors,
                marketState: marketState,
              ),
            ),

            const SizedBox(height: 16),

            // Controls — play button glow scales with market state
            _PlayerControls(mode: mode, marketState: marketState),

            const SizedBox(height: 18),

            LiveAnalyticsStrip(mode: mode),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AlbumArt
// ─────────────────────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.mode, required this.size});
  final SessionMode mode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
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
  const _PlayerControls({required this.mode, required this.marketState});
  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    // Glow intensity on the play button scales with market state
    final double glowBlur = (20 * marketState.glowScale).clamp(8.0, 40.0);
    final double glowOpacity = (0.45 * marketState.glowScale).clamp(0.15, 0.80);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GhostButton(
          icon: Icons.skip_previous_rounded,
          color: mode.onBackgroundMuted,
          size: 32,
        ),

        const SizedBox(width: 24),

        AnimatedContainer(
          duration: const Duration(milliseconds: 420),
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
                color: mode.primaryColor.withOpacity(glowOpacity),
                blurRadius: glowBlur,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.pause_rounded, color: Colors.white, size: 30),
        ),

        const SizedBox(width: 24),

        _GhostButton(
          icon: Icons.skip_next_rounded,
          color: mode.onBackgroundMuted,
          size: 32,
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
  });
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}
