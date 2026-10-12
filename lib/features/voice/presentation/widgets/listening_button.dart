import 'package:flutter/material.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// A large microphone that pulses while listening; tapping it finishes.
/// The pulse stops when the platform asks for reduced motion.
class ListeningButton extends StatefulWidget {
  const ListeningButton({required this.onStop, super.key});

  static const buttonKey = Key('voice.stop');

  final VoidCallback onStop;

  @override
  State<ListeningButton> createState() => _ListeningButtonState();
}

class _ListeningButtonState extends State<ListeningButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _pulse,
    curve: Curves.easeInOut,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 1.12,
  ).animate(_curve);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return ScaleTransition(
      scale: _scale,
      child: Semantics(
        button: true,
        label: l10n.voiceStop,
        excludeSemantics: true,
        child: Material(
          color: scheme.primary,
          shape: const CircleBorder(),
          child: InkWell(
            key: ListeningButton.buttonKey,
            customBorder: const CircleBorder(),
            onTap: widget.onStop,
            child: SizedBox.square(
              dimension: 96,
              child: Icon(Icons.mic, size: 44, color: scheme.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
