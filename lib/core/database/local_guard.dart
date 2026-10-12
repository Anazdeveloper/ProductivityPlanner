import 'dart:async';

import 'package:productivity_planner/core/error/failure.dart';
import 'package:productivity_planner/core/logging/error_reporter.dart';
import 'package:productivity_planner/core/result/result.dart';

/// Runs a local-storage operation, turning any exception into
/// `Failure.database` (and reporting it: local storage errors are bugs or
/// a full disk, never expected outcomes).
Future<Result<T>> guardLocal<T>(
  ErrorReporter reporter,
  String operation,
  Future<Result<T>> Function() body,
) async {
  try {
    return await body();
  } on Object catch (error, stackTrace) {
    unawaited(
      reporter.report(error, stackTrace, context: {'operation': operation}),
    );
    return Err(Failure.database(message: operation));
  }
}

/// Wraps each value of a database watch in [Ok]; an error becomes one
/// [Err] (reported) and the stream keeps going.
Stream<Result<T>> guardLocalStream<T>(
  ErrorReporter reporter,
  String operation,
  Stream<T> source,
) => source.transform(
  StreamTransformer<T, Result<T>>.fromHandlers(
    handleData: (value, sink) => sink.add(Ok(value)),
    handleError: (error, stackTrace, sink) {
      unawaited(
        reporter.report(error, stackTrace, context: {'operation': operation}),
      );
      sink.add(Err(Failure.database(message: operation)));
    },
  ),
);
