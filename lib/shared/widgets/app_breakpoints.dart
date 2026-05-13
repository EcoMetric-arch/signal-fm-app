// ─────────────────────────────────────────────────────────────────────────────
// AppBreakpoints
//
// Centralised breakpoint constants. Every layout decision in Phase 3 branches
// on these values so there is one place to tune them.
//
// Usage (inside a LayoutBuilder):
//   if (constraints.maxWidth < AppBreakpoints.tablet) {
//     return const _MobileLayout(...);
//   }
//   return const _TabletLayout(...);
// ─────────────────────────────────────────────────────────────────────────────

class AppBreakpoints {
  /// Anything below this width is treated as a phone in portrait.
  static const double mobile = 600;

  /// 600–1100 px → tablet / small desktop — uses the two-panel layout.
  static const double tablet = 1100;
}