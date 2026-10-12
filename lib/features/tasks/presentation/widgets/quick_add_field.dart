import 'package:flutter/material.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// One-line task entry: type a title and press enter to add an any-time
/// task; the tune button opens the full editor with the title filled in;
/// the microphone (when [onVoice] is set) adds a task by voice.
class QuickAddField extends StatefulWidget {
  const QuickAddField({
    required this.onSubmit,
    required this.onMoreOptions,
    this.onVoice,
    super.key,
  });

  static const fieldKey = Key('quickAdd.field');
  static const moreKey = Key('quickAdd.more');
  static const voiceKey = Key('quickAdd.voice');

  /// Returns whether the task was added (then the field is cleared).
  final Future<bool> Function(String title) onSubmit;
  final ValueChanged<String> onMoreOptions;
  final VoidCallback? onVoice;

  @override
  State<QuickAddField> createState() => _QuickAddFieldState();
}

class _QuickAddFieldState extends State<QuickAddField> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    final added = await widget.onSubmit(title);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (added) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onVoice = widget.onVoice;
    return TextField(
      key: QuickAddField.fieldKey,
      controller: _controller,
      // Read-only (not disabled) while saving keeps the keyboard open for
      // the next entry.
      readOnly: _submitting,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: l10n.quickAddHint,
        prefixIcon: const Icon(Icons.add),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onVoice != null)
              IconButton(
                key: QuickAddField.voiceKey,
                tooltip: l10n.addByVoice,
                icon: const Icon(Icons.mic_none),
                onPressed: onVoice,
              ),
            IconButton(
              key: QuickAddField.moreKey,
              tooltip: l10n.quickAddMoreOptions,
              icon: const Icon(Icons.tune),
              onPressed: () => widget.onMoreOptions(_controller.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}
