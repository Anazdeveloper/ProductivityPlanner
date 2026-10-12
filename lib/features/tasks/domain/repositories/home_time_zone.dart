/// The zone "today" is measured in when no series is involved (the agenda's
/// date, the default zone of a new task): the user's profile zone, or the
/// device's zone before the profile is known.
abstract interface class HomeTimeZone {
  Future<String> current();
}
