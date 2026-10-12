import 'package:productivity_planner/core/result/result.dart';

/// A single application action. Blocs depend on use cases, never on
/// repositories or data sources directly.
abstract interface class UseCase<Output, Params> {
  Future<Result<Output>> call(Params params);
}

/// A use case that observes data over time (e.g. today's occurrences from the
/// local database). Emits a new value whenever the underlying data changes.
abstract interface class StreamUseCase<Output, Params> {
  Stream<Result<Output>> call(Params params);
}

final class NoParams {
  const NoParams();
}
