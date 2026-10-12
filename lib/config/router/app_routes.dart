import 'package:productivity_planner/core/time/local_date.dart';

/// Every route path in one place. Screens navigate with these, never with
/// string literals.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const signIn = '/sign-in';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Shell tabs
  static const today = '/today';
  static const planner = '/planner';
  static const analytics = '/analytics';
  static const settings = '/settings';
  static const profile = '/settings/profile';
  static const notificationSettings = '/settings/notifications';
  static const syncSettings = '/settings/sync';

  // Full-screen routes above the shell
  static const createTask = '/tasks/new';
  static const voiceTask = '/tasks/voice';
  static const editTaskPattern = '/tasks/:taskId/edit';
  static const subscription = '/subscription';

  static const occurrencePattern = '/occurrences/:occurrenceId';
  static const activityPattern = 'activities/:lineageId';

  static String occurrence(String occurrenceId) =>
      '/occurrences/${Uri.encodeComponent(occurrenceId)}';

  /// The editor for a new task, optionally prefilled.
  static String newTask({LocalDate? date, String? title}) {
    final query = {
      if (date != null) 'date': date.toString(),
      if (title != null && title.isNotEmpty) 'title': title,
    };
    return query.isEmpty
        ? createTask
        : Uri(path: createTask, queryParameters: query).toString();
  }

  /// The editor for an existing task; schedule changes apply from [from].
  static String editTask(String taskId, {LocalDate? from}) {
    final path = '/tasks/${Uri.encodeComponent(taskId)}/edit';
    return from == null
        ? path
        : Uri(path: path, queryParameters: {'from': from.toString()})
              .toString();
  }

  static String activity(String lineageId) =>
      '$analytics/activities/${Uri.encodeComponent(lineageId)}';

  /// Routes reachable without a session.
  static const Set<String> publicPaths = {splash, signIn, register, forgotPassword};
}
