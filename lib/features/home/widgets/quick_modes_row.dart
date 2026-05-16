import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuickModesRow — Phase 7: labelled as "MANUAL OVERRIDE"
//
// Adaptive Mode is the primary system. This row lets users override it.
// The label change communicates that hierarchy without changing functionality.
// ─────────────────────────────────────────────────────────────────────────────

class QuickModesRow extends StatelessWidget {
  const QuickModesRow({
    required this.activeMode,
    required this.onModeChanged,
    super.key,
  });

  final SessionMode activeMode;
  final ValueChanged<SessionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'MANUAL OVERRIDE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: activeMode.onBackgroundMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Adaptive resumes automatically',
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFF6B82A0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 9),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: <Widget>[
              for (final SessionMode session
                  in SignalFmSessions.all) ...<Widget>[
                _ModeChip(
                  session: session,
                  isActive: session.id == activeMode.id,
                  activeMode: activeMode,
                  onTap: () => onModeChanged(session),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
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
    final Color accent = activeMode.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        constraints: const BoxConstraints(minWidth: 68),
        decoration: BoxDecoration(
          color: isActive
              ? accent.withOpacity(0.16)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isActive ? accent : Colors.white.withOpacity(0.11),
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: isActive
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withOpacity(0.25),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              session.quickModeIcon,
              size: 17,
              color: isActive ? accent : activeMode.onBackgroundMuted,
            ),
            const SizedBox(height: 4),
            Text(
              session.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? activeMode.onBackground
                    : activeMode.onBackgroundMuted,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
