import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AiDjBar
//
// A single-line ambient intelligence readout shown above the bottom nav.
// NOT a chatbot. NOT a notification. Just a calm, premium intelligence layer.
//
// Behavior:
//   • On session or market state change, the message fades out then in with
//     a slow typewriter reveal (character by character, no external deps).
//   • The bar itself uses a frosted translucent surface — identical language
//     to the rest of the card system.
//   • A small "AI" monogram + session accent pulse sits to the left.
//
// The message text comes from MarketStateData.aiDjMessage (market-state-aware)
// rather than session.analytics.aiDjNote (session-aware). Both exist; the
// bar shows the market state message because it's the more dynamic layer.
// ─────────────────────────────────────────────────────────────────────────────

class AiDjBar extends StatefulWidget {
  const AiDjBar({
    required this.mode,
    required this.marketState,
    super.key,
  });

  final SessionMode mode;
  final MarketStateData marketState;

  @override
  State<AiDjBar> createState() => _AiDjBarState();
}

class _AiDjBarState extends State<AiDjBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  String _displayMessage = '';
  String _targetMessage = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _targetMessage = widget.marketState.aiDjMessage;
    _startReveal();
  }

  @override
  void didUpdateWidget(AiDjBar old) {
    super.didUpdateWidget(old);
    final newMsg = widget.marketState.aiDjMessage;
    if (newMsg != _targetMessage) {
      _targetMessage = newMsg;
      _ctrl.reverse().then((_) {
        if (mounted) {
          setState(() {
            _displayMessage = '';
            _charIndex = 0;
          });
          _startReveal();
        }
      });
    }
  }

  void _startReveal() {
    _ctrl.forward(from: 0);
    _revealNextChar();
  }

  void _revealNextChar() {
    if (!mounted) return;
    if (_charIndex >= _targetMessage.length) return;
    // 28 ms per character — unhurried, premium pace
    Future.delayed(const Duration(milliseconds: 28), () {
      if (!mounted) return;
      setState(() {
        _charIndex++;
        _displayMessage = _targetMessage.substring(0, _charIndex);
      });
      _revealNextChar();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mode.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mode.surfaceBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: mode.primaryColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── AI monogram ────────────────────────────────────────────
            _AiMonogram(mode: mode),

            const SizedBox(width: 12),

            // ── Message ────────────────────────────────────────────────
            Expanded(
              child: Text(
                _displayMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: mode.onBackground,
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ── State label ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: mode.primaryColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.marketState.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: mode.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AiMonogram — "AI" text in a pulsing accent circle
// ─────────────────────────────────────────────────────────────────────────────

class _AiMonogram extends StatefulWidget {
  const _AiMonogram({required this.mode});
  final SessionMode mode;

  @override
  State<_AiMonogram> createState() => _AiMonogramState();
}

class _AiMonogramState extends State<_AiMonogram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mode.primaryColor.withOpacity(0.14),
            border: Border.all(
              color: mode.primaryColor.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              'AI',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: mode.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
