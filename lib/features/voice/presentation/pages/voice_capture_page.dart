import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/failure_message.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_prefill.dart';
import 'package:productivity_planner/features/voice/domain/entities/speech.dart';
import 'package:productivity_planner/features/voice/presentation/bloc/voice_capture_bloc.dart';
import 'package:productivity_planner/features/voice/presentation/widgets/listening_button.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Renders a draft's fields for review (supplied by the router from the
/// tasks feature, so voice does not depend on its widgets).
typedef PrefillSummaryBuilder =
    Widget Function(TaskPrefill prefill, LocalDate today, String? categoryName);

/// Add a task by voice: listen, show what was heard and understood, then
/// hand the draft to the task editor, where the person confirms. Typing
/// works too (no microphone access, a noisy room, a correction).
/// Expects a [VoiceCaptureBloc].
class VoiceCapturePage extends StatelessWidget {
  const VoiceCapturePage({
    required this.onReview,
    required this.onClose,
    required this.summaryBuilder,
    super.key,
  });

  static const continueKey = Key('voice.continue');
  static const retryKey = Key('voice.retry');
  static const typedFieldKey = Key('voice.typed');

  /// Opens the editor with the draft.
  final ValueChanged<TaskPrefill> onReview;
  final VoidCallback onClose;
  final PrefillSummaryBuilder summaryBuilder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.actionClose,
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        title: Text(l10n.voiceTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: BlocBuilder<VoiceCaptureBloc, VoiceCaptureState>(
              builder: (context, state) => ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  ..._phase(context, state),
                  if (state.phase != VoicePhase.listening &&
                      state.phase != VoicePhase.preparing &&
                      state.phase != VoicePhase.understanding) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _TypedEntry(
                      key: ValueKey(state.transcript),
                      initial: state.transcript,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _phase(BuildContext context, VoiceCaptureState state) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bloc = context.read<VoiceCaptureBloc>();
    switch (state.phase) {
      case VoicePhase.preparing:
        return const [
          SizedBox(height: AppSpacing.xl),
          Center(child: CircularProgressIndicator()),
        ];
      case VoicePhase.listening:
        return [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: ListeningButton(
              onStop: () => bloc.add(const VoiceStopPressed()),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            liveRegion: true,
            child: Text(
              state.transcript.isEmpty
                  ? l10n.voiceListening
                  : state.transcript,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.voiceExample,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ];
      case VoicePhase.understanding:
        return [
          const SizedBox(height: AppSpacing.xl),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: AppSpacing.md),
          _Heard(text: state.transcript),
        ];
      case VoicePhase.review:
        final draft = state.draft;
        if (draft == null) return const [];
        return [
          _Heard(text: draft.text),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              l10n.voiceUnderstood,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          summaryBuilder(draft.toPrefill(), draft.today, draft.category?.name),
          if (!draft.hasDetails) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.voiceOnlyTitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            key: continueKey,
            onPressed: () => onReview(draft.toPrefill()),
            child: Text(l10n.voiceContinue),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: retryKey,
            onPressed: () => bloc.add(const VoiceRetryPressed()),
            icon: const Icon(Icons.mic_none),
            label: Text(l10n.voiceTryAgain),
          ),
        ];
      case VoicePhase.unavailable:
        return [
          NoticeBanner(
            text: state.availability == SpeechAvailability.permissionDenied
                ? l10n.permissionMicrophoneDenied
                : l10n.voiceUnsupported,
            icon: Icons.mic_off_outlined,
          ),
          if (state.availability == SpeechAvailability.permissionDenied) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                key: retryKey,
                onPressed: () => bloc.add(const VoiceRetryPressed()),
                child: Text(l10n.voiceTryAgain),
              ),
            ),
          ],
        ];
      case VoicePhase.failed:
        final failure = state.failure;
        return [
          if (state.transcript.isNotEmpty) ...[
            _Heard(text: state.transcript),
            const SizedBox(height: AppSpacing.md),
          ],
          NoticeBanner(
            text: failure != null
                ? failure.message(l10n)
                : _errorText(state.error, l10n),
            icon: Icons.error_outline,
            isError: true,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: retryKey,
            onPressed: () => bloc.add(const VoiceRetryPressed()),
            icon: const Icon(Icons.mic_none),
            label: Text(l10n.voiceTryAgain),
          ),
        ];
    }
  }

  static String _errorText(SpeechErrorKind? kind, AppLocalizations l10n) =>
      switch (kind) {
        SpeechErrorKind.noSpeech || null => l10n.voiceNothingHeard,
        SpeechErrorKind.network => l10n.voiceNetwork,
        SpeechErrorKind.busy => l10n.voiceBusy,
        SpeechErrorKind.permissionDenied => l10n.permissionMicrophoneDenied,
        SpeechErrorKind.unknown => l10n.voiceFailed,
      };
}

/// The sentence as heard, in quotes.
class _Heard extends StatelessWidget {
  const _Heard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      AppLocalizations.of(context).voiceHeard(text),
      style: theme.textTheme.titleLarge,
      textAlign: TextAlign.center,
    );
  }
}

/// Type (or fix) the sentence instead of saying it.
class _TypedEntry extends StatefulWidget {
  const _TypedEntry({required this.initial, super.key});

  final String initial;

  @override
  State<_TypedEntry> createState() => _TypedEntryState();
}

class _TypedEntryState extends State<_TypedEntry> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => context.read<VoiceCaptureBloc>().add(
    VoiceTextSubmitted(_controller.text),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      key: VoiceCapturePage.typedFieldKey,
      controller: _controller,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        labelText: l10n.voiceTypeInstead,
        hintText: l10n.voiceExampleShort,
        suffixIcon: IconButton(
          tooltip: l10n.voiceUnderstand,
          icon: const Icon(Icons.arrow_forward),
          onPressed: _submit,
        ),
      ),
    );
  }
}
