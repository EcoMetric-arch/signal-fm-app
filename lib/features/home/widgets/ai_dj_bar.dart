import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AiDjBar — ambient AI intelligence readout above bottom nav
// Dart compatibility: Dart 2.17+, no records, no abstract final class.
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
    final String newMsg = widget.marketState.aiDjMessage;
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
    Future<void>.delayed(const Duration(milliseconds: 28), () {
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
    final SessionMode mode = widget.mode;
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.13),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: mode.primaryColor.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            _AiMonogram(mode: mode),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _displayMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFD8E0F0),
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: mode.primaryColor.withOpacity(0.12),
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
    final SessionMode mode = widget.mode;
    return AnimatedBuilder(
      animation: _scale,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
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
        );
      },
    );
  }
}
