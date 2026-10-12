import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/usecase/use_case.dart';
import 'package:productivity_planner/features/voice/domain/entities/parsed_task.dart';
import 'package:productivity_planner/features/voice/domain/entities/speech.dart';
import 'package:productivity_planner/features/voice/domain/usecases/voice_usecases.dart';

part 'voice_capture_bloc.freezed.dart';

// Events

sealed class VoiceCaptureEvent {
  const VoiceCaptureEvent();
}

/// Prepares the recognizer and starts listening. Sent once by the route.
final class VoiceCaptureStarted extends VoiceCaptureEvent {
  const VoiceCaptureStarted();
}

/// Done talking: finish now instead of waiting for a pause.
final class VoiceStopPressed extends VoiceCaptureEvent {
  const VoiceStopPressed();
}

/// Listen again from scratch.
final class VoiceRetryPressed extends VoiceCaptureEvent {
  const VoiceRetryPressed();
}

/// A typed (or corrected) sentence, parsed instead of speech.
final class VoiceTextSubmitted extends VoiceCaptureEvent {
  const VoiceTextSubmitted(this.text);

  final String text;
}

final class _SpeechReceived extends VoiceCaptureEvent {
  const _SpeechReceived(this.event, this.session);

  final SpeechEvent event;
  final int session;
}

// State

enum VoicePhase {
  preparing,
  listening,
  understanding,

  /// A draft is ready to review.
  review,

  /// Speech cannot be used (no permission, no recognizer); typing works.
  unavailable,

  /// This attempt failed (nothing heard, network); try again or type.
  failed,
}

@freezed
abstract class VoiceCaptureState with _$VoiceCaptureState {
  const factory VoiceCaptureState({
    @Default(VoicePhase.preparing) VoicePhase phase,

    /// What was heard so far (live while listening).
    @Default('') String transcript,
    ParsedTask? draft,
    SpeechAvailability? availability,
    SpeechErrorKind? error,
    Failure? failure,
  }) = _VoiceCaptureState;
}

/// Voice task creation, steps 1–3 of the pipeline: listen, transcribe,
/// extract a draft. Step 4 (confirmation) is the task editor, opened with
/// the draft; nothing is saved here.
///
/// A Bloc rather than a Cubit: recognizer events and taps interleave, and
/// events from an abandoned listening session must be ignored.
final class VoiceCaptureBloc extends Bloc<VoiceCaptureEvent, VoiceCaptureState> {
  VoiceCaptureBloc({
    required PrepareSpeech prepareSpeech,
    required ListenForSpeech listenForSpeech,
    required StopListening stopListening,
    required ParseSpokenTask parseSpokenTask,
  }) : _prepareSpeech = prepareSpeech,
       _listenForSpeech = listenForSpeech,
       _stopListening = stopListening,
       _parseSpokenTask = parseSpokenTask,
       super(const VoiceCaptureState()) {
    on<VoiceCaptureStarted>(_onStarted);
    on<VoiceStopPressed>(_onStop);
    on<VoiceRetryPressed>(_onRetry);
    on<VoiceTextSubmitted>(_onTextSubmitted);
    on<_SpeechReceived>(_onSpeech);
  }

  final PrepareSpeech _prepareSpeech;
  final ListenForSpeech _listenForSpeech;
  final StopListening _stopListening;
  final ParseSpokenTask _parseSpokenTask;

  StreamSubscription<SpeechEvent>? _listening;

  /// Increments with every listening session and parse, so late results
  /// of an abandoned one are dropped.
  int _session = 0;

  Future<void> _onStarted(
    VoiceCaptureStarted event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    emit(const VoiceCaptureState());
    final availability =
        (await _prepareSpeech(const NoParams())).valueOrNull ??
        SpeechAvailability.unsupported;
    if (availability != SpeechAvailability.available) {
      emit(
        state.copyWith(
          phase: VoicePhase.unavailable,
          availability: availability,
        ),
      );
      return;
    }
    emit(state.copyWith(availability: availability));
    await _listen(emit);
  }

  Future<void> _listen(Emitter<VoiceCaptureState> emit) async {
    await _listening?.cancel();
    // Closed while preparing (the page was left): never open the mic.
    if (isClosed || emit.isDone) return;
    final session = ++_session;
    emit(
      state.copyWith(
        phase: VoicePhase.listening,
        transcript: '',
        draft: null,
        error: null,
        failure: null,
      ),
    );
    _listening = _listenForSpeech().listen(
      (event) => add(_SpeechReceived(event, session)),
    );
  }

  Future<void> _onStop(
    VoiceStopPressed event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (state.phase != VoicePhase.listening) return;
    // The final transcript follows on the speech stream.
    await _stopListening(const NoParams());
  }

  Future<void> _onRetry(
    VoiceRetryPressed event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (state.availability == SpeechAvailability.available) {
      await _listen(emit);
    } else {
      add(const VoiceCaptureStarted());
    }
  }

  Future<void> _onTextSubmitted(
    VoiceTextSubmitted event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    final text = event.text.trim();
    if (text.isEmpty) return;
    await _listening?.cancel();
    _listening = null;
    await _understand(text, emit);
  }

  Future<void> _onSpeech(
    _SpeechReceived event,
    Emitter<VoiceCaptureState> emit,
  ) async {
    if (event.session != _session) return;
    switch (event.event) {
      case SpeechPartial(:final text):
        emit(state.copyWith(transcript: text));
      case SpeechFinal(:final text):
        if (text.trim().isEmpty) {
          emit(
            state.copyWith(
              phase: VoicePhase.failed,
              error: SpeechErrorKind.noSpeech,
            ),
          );
        } else {
          await _understand(text, emit);
        }
      case SpeechFailed(kind: SpeechErrorKind.permissionDenied):
        emit(
          state.copyWith(
            phase: VoicePhase.unavailable,
            availability: SpeechAvailability.permissionDenied,
          ),
        );
      case SpeechFailed(:final kind):
        // Keep what was heard before the error: it may be enough.
        if (state.transcript.trim().isNotEmpty) {
          await _understand(state.transcript, emit);
        } else {
          emit(state.copyWith(phase: VoicePhase.failed, error: kind));
        }
    }
  }

  Future<void> _understand(String text, Emitter<VoiceCaptureState> emit) async {
    final session = ++_session;
    emit(
      state.copyWith(
        phase: VoicePhase.understanding,
        transcript: text,
        error: null,
        failure: null,
      ),
    );
    final result = await _parseSpokenTask(text);
    if (session != _session) return;
    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(phase: VoicePhase.review, draft: value));
      case Err(:final failure):
        emit(state.copyWith(phase: VoicePhase.failed, failure: failure));
    }
  }

  @override
  Future<void> close() async {
    await _listening?.cancel();
    await super.close();
  }
}
