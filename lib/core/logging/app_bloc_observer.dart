import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:productivity_planner/core/logging/app_logger.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';

/// Logs bloc lifecycle and reports bloc errors. Logs **types only**, never
/// state contents, because states can hold task titles and notes.
final class AppBlocObserver extends BlocObserver {
  const AppBlocObserver({
    required AppLogger logger,
    required ErrorReporter reporter,
  }) : _logger = logger,
       _reporter = reporter;

  final AppLogger _logger;
  final ErrorReporter _reporter;

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _logger.debug(
      'bloc transition',
      context: {
        'bloc': bloc.runtimeType.toString(),
        'event': transition.event.runtimeType.toString(),
        'next': transition.nextState.runtimeType.toString(),
      },
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    unawaited(
      _reporter.report(
        error,
        stackTrace,
        context: {'bloc': bloc.runtimeType.toString()},
      ),
    );
  }
}
