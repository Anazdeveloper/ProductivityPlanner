import 'package:freezed_annotation/freezed_annotation.dart' show immutable;
import 'package:productivity_planner/core/error/failure.dart';

/// Outcome of an operation that can fail in an expected way.
///
/// Deliberately small: Dart 3 sealed classes + pattern matching cover what
/// dartz/fpdart would provide, with no dependency.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Err<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Ok<T>() => null,
    Err<T>(:final failure) => failure,
  };

  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Failure failure) onErr,
  }) => switch (this) {
    Ok<T>(:final value) => onOk(value),
    Err<T>(:final failure) => onErr(failure),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok<T>(:final value) => Ok<R>(transform(value)),
    Err<T>(:final failure) => Err<R>(failure),
  };

  /// Chains a second fallible async step; short-circuits on the first failure.
  Future<Result<R>> andThen<R>(Future<Result<R>> Function(T value) next) async {
    switch (this) {
      case Ok<T>(:final value):
        return await next(value);
      case Err<T>(:final failure):
        return Err<R>(failure);
    }
  }
}

@immutable
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Ok<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);

  @override
  String toString() => 'Ok($value)';
}

@immutable
final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Err<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err, failure);

  @override
  String toString() => 'Err($failure)';
}

/// Value for operations that succeed with nothing to return.
final class Unit {
  const Unit._();

  @override
  String toString() => 'unit';
}

const Unit unit = Unit._();
