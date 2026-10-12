import 'package:uuid/uuid.dart';

/// Creates ids for new entities, sync operations and requests.
/// Injected so tests can produce predictable ids.
abstract interface class IdGenerator {
  /// A new time-ordered UUIDv7 (good B-tree locality on the server).
  String newId();
}

final class UuidV7IdGenerator implements IdGenerator {
  const UuidV7IdGenerator();

  static const _uuid = Uuid();

  @override
  String newId() => _uuid.v7();
}

/// The id of a series' occurrence on its original local date.
///
/// `UUIDv5(namespace: seriesId, name: "YYYY-MM-DD")`, identical on every
/// device and on the server, so an occurrence expanded offline on two phones
/// is the same row everywhere. Only the calendar fields of [originalLocalDate]
/// are used; no time-zone conversion happens here.
///
/// Verified against `contracts/vectors/occurrence_ids.json`.
String occurrenceIdFor({
  required String seriesId,
  required DateTime originalLocalDate,
}) {
  return deterministicId(
    namespace: seriesId,
    name: formatLocalDate(originalLocalDate),
  );
}

/// `UUIDv5(namespace, name)`: the same id on every device and on the server
/// for the same inputs. Used for occurrences and for seeded rows such as
/// default categories (`UUIDv5(user_id, "category:work")`, contract §4.2).
///
/// Throws [ArgumentError] when [namespace] is not a UUID.
String deterministicId({required String namespace, required String name}) {
  if (!Uuid.isValidUUID(fromString: namespace)) {
    throw ArgumentError.value(namespace, 'namespace', 'must be a UUID');
  }
  return const Uuid().v5(namespace, name);
}

/// `YYYY-MM-DD` from the calendar fields of [date].
String formatLocalDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
