import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';
import 'waveform_painter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AlbumPlayerCard — hero player section
// Dart compatibility: Dart 2.17+, no records, no abstract final class.
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
      children: <Widget>[
        _ArtworkRing(mode: mode, marketState: marketState),
        const SizedBox(height: 12),
        _TrackInfoRow(mode: mode),
        const SizedBox(height: 12),
        _WaveformSection(mode: mode, marketState: marketState),
        const SizedBox(height: 12),
        _PlaybackControls(mode: mode, marketState: marketState),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ArtworkRing — clean 2px border + focused BoxShadow glow (no SweepGradient)
// ─────────────────────────────────────────────────────────────────────────────

class _ArtworkRing extends StatelessWidget {
  const _ArtworkRing({required this.mode, required this.marketState});

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    final double glowBlur =
        (32.0 * marketState.glowScale).clamp(14.0, 64.0);
    final double glowOpacity =
        (0.55 * marketState.glowScale).clamp(0.20, 0.85);
    final double outerBlur =
        (56.0 * marketState.glowScale).clamp(20.0, 90.0);
    final double outerOpacity =
        (0.22 * marketState.glowScale).clamp(0.06, 0.38);

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOut,
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: mode.primaryColor,
            width: 2.0,
          ),
          boxShadow: <BoxShadow>[
            // Focused inner glow — tight bright core
            BoxShadow(
              color: mode.primaryColor.withOpacity(glowOpacity),
              blurRadius: glowBlur,
              spreadRadius: 0,
            ),
            // Wide outer atmospheric halo
            BoxShadow(
              color: mode.primaryColor.withOpacity(outerOpacity),
              blurRadius: outerBlur,
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipOval(
              child: Image.asset(
                'assets/images/album_art.png',
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
// _TrackInfoRow
// ─────────────────────────────────────────────────────────────────────────────

class _TrackInfoRow extends StatelessWidget {
  const _TrackInfoRow({required this.mode});

  final SessionMode mode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder:
                    (Widget child, Animation<double> anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  mode.title,
                  key: ValueKey<String>('${mode.id}_title'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF5F6FA),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mode.stationName,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B82A0),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                mode.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B82A0),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Icon(Icons.favorite_border_rounded,
                size: 19, color: mode.onBackgroundMuted),
            const SizedBox(width: 14),
            Icon(Icons.more_horiz_rounded,
                size: 19, color: mode.onBackgroundMuted),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WaveformSection
// ─────────────────────────────────────────────────────────────────────────────

class _WaveformSection extends StatelessWidget {
  const _WaveformSection({required this.mode, required this.marketState});

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 44,
          child: WaveformDisplay(
            accentColor: mode.primaryColor,
            waveformColors: mode.waveformColors,
            marketState: marketState,
          ),
        ),
        const SizedBox(height: 5),

        // Progress track
        Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.46,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: <Color>[
                      mode.primaryColor,
                      mode.primaryColor.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.46,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: mode.primaryColor.withOpacity(0.70),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
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
// _PlaybackControls — shuffle / prev / play / next / repeat
// ─────────────────────────────────────────────────────────────────────────────

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({required this.mode, required this.marketState});

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  Widget build(BuildContext context) {
    final double glowBlur =
        (16.0 * marketState.glowScale).clamp(8.0, 32.0);
    final double glowOpacity =
        (0.50 * marketState.glowScale).clamp(0.18, 0.80);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(Icons.shuffle_rounded,
            size: 20, color: mode.onBackgroundMuted),
        Icon(Icons.skip_previous_rounded,
            size: 28, color: const Color(0xFFDDE4F0)),
        AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mode.primaryColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: mode.primaryColor.withOpacity(glowOpacity),
                blurRadius: glowBlur,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.pause_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        Icon(Icons.skip_next_rounded,
            size: 28, color: const Color(0xFFDDE4F0)),
        Icon(Icons.repeat_rounded,
            size: 20, color: mode.onBackgroundMuted),
      ],
    );
  }
}
