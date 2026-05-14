import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuickModesRow  (Phase 6)
//
// Matches reference section 10 (Quick Modes):
//   "QUICK MODES" label + "View all" on the right
//   5 chips below in a horizontal scroll row
//   Active chip: filled background + glow border + white label
//   Inactive: ghost/translucent
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
      children: [
        // ── Header row ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'QUICK MODES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: activeMode.onBackgroundMuted,
              ),
            ),
            Text(
              'View all',
              style: TextStyle(
                fontSize: 10,
                color: activeMode.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Chips ───────────────────────────────────────────────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              for (final session in SignalFmSessions.all) ...[
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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(minWidth: 72),
        decoration: BoxDecoration(
          color: isActive
              ? accent.withOpacity(0.18)
              : activeMode.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? accent : activeMode.surfaceBorder,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.30),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              session.quickModeIcon,
              size: 18,
              color: isActive ? accent : activeMode.onBackgroundMuted,
            ),
            const SizedBox(height: 5),
            Text(
              session.displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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
