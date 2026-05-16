import 'package:flutter/material.dart';

import '../../../shared/theme/signal_fm_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AiDjBar — Phase 7: engine brain of the app
//
// Phase 7 changes:
//   • Shows aiDjEngineNote (what the engine is doing) instead of generic message.
//     Example: "Volatility rising. Reducing ambience density. Focus layer active."
//   • Market state chip moved here for prominence — this IS the brain display.
//   • AI orb scales with glowScale — pulsing faster during high-energy states.
//   • Typewriter reveal restarts on both session AND market state change.
//
// Phase 8 integration: replace MarketStateData.aiDjEngineNote with
// a real-time string from the AI DJ Engine service.
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
  String _displayed = '';
  String _target = '';
  int _charIdx = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _target = widget.marketState.aiDjEngineNote;
    _start();
  }

  @override
  void didUpdateWidget(AiDjBar old) {
    super.didUpdateWidget(old);
    final String next = widget.marketState.aiDjEngineNote;
    if (next != _target) {
      _target = next;
      _ctrl.reverse().then((_) {
        if (mounted) {
          setState(() {
            _displayed = '';
            _charIdx = 0;
          });
          _start();
        }
      });
    }
  }

  void _start() {
    _ctrl.forward(from: 0);
    _tick();
  }

  void _tick() {
    if (!mounted || _charIdx >= _target.length) return;
    Future<void>.delayed(const Duration(milliseconds: 24), () {
      if (!mounted) return;
      setState(() {
        _charIdx++;
        _displayed = _target.substring(0, _charIdx);
      });
      _tick();
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
    final MarketStateData ms = widget.marketState;

    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: mode.primaryColor.withOpacity(0.18),
            width: 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: mode.primaryColor.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            // AI orb — pulses faster during high-energy states
            _AiOrb(mode: mode, glowScale: ms.glowScale),
            const SizedBox(width: 10),
            // Engine note — typewriter
            Expanded(
              child: Text(
                _displayed,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFD8E0F0),
                  letterSpacing: 0.1,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // State chip
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Container(
                key: ValueKey<String>(ms.label),
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ms.stateColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: ms.stateColor.withOpacity(0.38),
                    width: 1,
                  ),
                ),
                child: Text(
                  ms.label,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: ms.stateColor,
                  ),
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
// _AiOrb — pulse speed driven by glowScale
// ─────────────────────────────────────────────────────────────────────────────

class _AiOrb extends StatefulWidget {
  const _AiOrb({required this.mode, required this.glowScale});

  final SessionMode mode;
  final double glowScale;

  @override
  State<_AiOrb> createState() => _AiOrbState();
}

class _AiOrbState extends State<_AiOrb> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: _pulseDuration(),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AiOrb old) {
    super.didUpdateWidget(old);
    if (old.glowScale != widget.glowScale) {
      _pulse.duration = _pulseDuration();
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    }
  }

  // Faster pulse during high-energy market states
  Duration _pulseDuration() {
    final int ms = (2000 / widget.glowScale.clamp(0.5, 2.0)).round();
    return Duration(milliseconds: ms);
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
      animation: _pulse,
      builder: (BuildContext context, Widget? child) {
        return Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: mode.primaryColor.withOpacity(0.12),
            border: Border.all(
              color: mode.primaryColor
                  .withOpacity(0.28 + _pulse.value * 0.28),
              width: 1.2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: mode.primaryColor
                    .withOpacity(0.18 + _pulse.value * 0.18),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              'AI',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: mode.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
