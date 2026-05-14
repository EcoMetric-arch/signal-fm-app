import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';
import 'waveform_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AlbumPlayerCard  (Phase 6)
//
// Matches the reference hero section precisely:
//   • Large circular album art with multi-layer glow ring
//   • Track title + station name + subtitle row + ♥ and ⋯ icons
//   • Waveform with playhead line + timestamps (1:48 / 3:58)
//   • 5-button controls: shuffle ← prev ⏸ next → repeat
//
// NO analytics inside this card — analytics live in LiveAnalyticsStrip below.
// RULE: never returns Expanded at root.
// ─────────────────────────────────────────────────────────────────────────────

class AlbumPlayerCard extends StatelessWidget {
  const AlbumPlayerCard({
    required this.mode,
    required this.marketState,
    super.key,
  });

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Large circular artwork ──────────────────────────────────────
        _ArtworkRing(mode: mode, marketState: marketState),

        const SizedBox(height: 14),

        // ── Track info row ──────────────────────────────────────────────
        _TrackInfoRow(mode: mode),

        const SizedBox(height: 14),

        // ── Waveform + progress ─────────────────────────────────────────
        _WaveformSection(mode: mode, marketState: marketState),

        const SizedBox(height: 14),

        // ── Playback controls ───────────────────────────────────────────
        _PlaybackControls(mode: mode, marketState: marketState),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ArtworkRing
// ─────────────────────────────────────────────────────────────────────────────

class _ArtworkRing extends StatelessWidget {
  const _ArtworkRing({required this.mode, required this.marketState});
  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    final double glowBlur = (40 * marketState.glowScale).clamp(16.0, 80.0);
    final double glowOpacity = (0.45 * marketState.glowScale).clamp(0.15, 0.80);

    return Center(
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow halo
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mode.primaryColor.withOpacity(glowOpacity * 0.6),
                    blurRadius: glowBlur * 1.4,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            // Gradient ring border
            AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    mode.primaryColor,
                    mode.primaryColor.withOpacity(0.3),
                    mode.secondaryColor,
                    mode.primaryColor,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mode.backgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
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
              ),
            ),
            // Inner glow ring overlay
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mode.primaryColor.withOpacity(glowOpacity * 0.35),
                    blurRadius: glowBlur * 0.5,
                    spreadRadius: -4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TrackInfoRow — title + station + subtitle + ♥ + ⋯
// ─────────────────────────────────────────────────────────────────────────────

class _TrackInfoRow extends StatelessWidget {
  const _TrackInfoRow({required this.mode});
  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  mode.title,
                  key: ValueKey('${mode.id}_title'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: mode.onBackground,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mode.stationName,
                style: TextStyle(
                  fontSize: 12,
                  color: mode.onBackgroundMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 1),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  mode.subtitle,
                  key: ValueKey('${mode.id}_sub'),
                  style: TextStyle(
                    fontSize: 11,
                    color: mode.onBackgroundMuted,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Icons
        Row(
          children: [
            Icon(Icons.favorite_border_rounded,
                size: 20, color: mode.onBackgroundMuted),
            const SizedBox(width: 14),
            Icon(Icons.more_horiz_rounded,
                size: 20, color: mode.onBackgroundMuted),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WaveformSection — waveform + progress slider + timestamps
// ─────────────────────────────────────────────────────────────────────────────

class _WaveformSection extends StatelessWidget {
  const _WaveformSection({required this.mode, required this.marketState});
  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Waveform
        SizedBox(
          height: 48,
          child: WaveformDisplay(
            accentColor: mode.primaryColor,
            waveformColors: mode.waveformColors,
            marketState: marketState,
          ),
        ),
        const SizedBox(height: 6),

        // Progress line + playhead dot
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: mode.onBackgroundMuted.withOpacity(0.25),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.46, // 1:48 / 3:58 ≈ 0.46
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: mode.primaryColor,
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.46,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mode.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: mode.primaryColor.withOpacity(0.55),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // Timestamps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1:48',
              style: TextStyle(
                fontSize: 10,
                color: mode.onBackgroundMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '3:58',
              style: TextStyle(
                fontSize: 10,
                color: mode.onBackgroundMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PlaybackControls — shuffle, prev, play/pause, next, repeat
// ─────────────────────────────────────────────────────────────────────────────

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.mode, required this.marketState});
  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    final double glowBlur = (18 * marketState.glowScale).clamp(8.0, 36.0);
    final double glowOpacity =
        (0.45 * marketState.glowScale).clamp(0.15, 0.80);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        Icon(Icons.shuffle_rounded,
            size: 20, color: mode.onBackgroundMuted),

        // Previous
        Icon(Icons.skip_previous_rounded,
            size: 28, color: mode.onBackground.withOpacity(0.85)),

        // Play/Pause — large accent button
        AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mode.primaryColor,
            boxShadow: [
              BoxShadow(
                color: mode.primaryColor.withOpacity(glowOpacity),
                blurRadius: glowBlur,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.pause_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),

        // Next
        Icon(Icons.skip_next_rounded,
            size: 28, color: mode.onBackground.withOpacity(0.85)),

        // Repeat
        Icon(Icons.repeat_rounded,
            size: 20, color: mode.onBackgroundMuted),
      ],
    );
  }
}
