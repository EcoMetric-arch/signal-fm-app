import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuickModesRow  (Phase 3 — minimal changes)
//
// Changes: chip padding tightened for mobile, AnimatedContainer duration
// aligned with the rest of the Phase 3 animation budget (220 ms).
// Interface unchanged.
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final session in SignalFmSessions.all) ...[
            _QuickChip(
              session: session,
              isActive: session.id == activeMode.id,
              activeMode: activeMode,
              onTap: () => onModeChanged(session),
            ),
            const SizedBox(width: 7),
          ],
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? accent.withOpacity(0.16)
              : activeMode.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? accent : activeMode.surfaceBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              session.quickModeIcon,
              size: 12,
              color: isActive ? accent : activeMode.onBackgroundMuted,
            ),
            const SizedBox(width: 5),
            Text(
              session.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? activeMode.onBackground
                    : activeMode.onBackgroundMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}