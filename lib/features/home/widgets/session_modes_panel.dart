import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SessionModesPanel  (Phase 3)
//
// Changes from Phase 2:
//   • Outer container uses AnimatedContainer for smooth color transitions.
//   • _ModeButton also uses AnimatedContainer (was already done in Phase 2 —
//     kept and improved with a subtle right-side accent bar on active item).
// ─────────────────────────────────────────────────────────────────────────────

class SessionModesPanel extends StatelessWidget {
  const SessionModesPanel({
    required this.activeMode,
    required this.onModeChanged,
    super.key,
  });

  final SessionMode activeMode;
  final ValueChanged<SessionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: activeMode.surfaceColor,
        border: Border.all(color: activeMode.surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 10),
            child: Text(
              'Session Modes',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: activeMode.onBackgroundMuted,
              ),
            ),
          ),

          // ── 5 mode buttons ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: SignalFmSessions.all
                    .map((session) => _ModeButton(
                          session: session,
                          isActive: session.id == activeMode.id,
                          activeMode: activeMode,
                          onTap: () => onModeChanged(session),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ModeButton
// ─────────────────────────────────────────────────────────────────────────────

class _ModeButton extends StatelessWidget {
  const _ModeButton({
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
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isActive ? accent.withOpacity(0.14) : Colors.transparent,
          border: Border.all(
            color: isActive ? accent.withOpacity(0.55) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Session icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? accent.withOpacity(0.18)
                    : activeMode.surfaceBorder.withOpacity(0.5),
              ),
              child: Icon(
                session.quickModeIcon,
                size: 15,
                color: isActive ? accent : activeMode.onBackgroundMuted,
              ),
            ),

            const SizedBox(width: 10),

            // Session name
            Expanded(
              child: Text(
                session.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? activeMode.onBackground
                      : activeMode.onBackgroundMuted,
                ),
              ),
            ),

            // Active indicator
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
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