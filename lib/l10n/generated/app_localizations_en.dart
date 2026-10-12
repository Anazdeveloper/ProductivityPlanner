// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Planner';

  @override
  String get tabToday => 'Today';

  @override
  String get tabPlanner => 'Planner';

  @override
  String get tabInsights => 'Insights';

  @override
  String get tabSettings => 'Settings';

  @override
  String get actionClose => 'Close';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionGoToToday => 'Go to Today';

  @override
  String get notFoundMessage => 'This page doesn\'t exist.';

  @override
  String get failureNetwork =>
      'You\'re offline or the server can\'t be reached. Your changes are saved on this device.';

  @override
  String get failureUnauthenticated =>
      'Your session has ended. Please sign in again.';

  @override
  String get failureForbidden => 'You don\'t have access to that.';

  @override
  String get failureValidation => 'Please check the highlighted fields.';

  @override
  String get failureNotFound => 'That item doesn\'t exist anymore.';

  @override
  String get failureServer =>
      'Something went wrong on our side. Please try again.';

  @override
  String get failureDatabase =>
      'We couldn\'t save that on this device. Please try again.';

  @override
  String get failureEntitlementRequired => 'This is a Premium feature.';

  @override
  String get failureLimitReached =>
      'You\'ve reached your plan\'s limit. Upgrade to add more.';

  @override
  String get failureUnexpected =>
      'Something unexpected happened. Please try again.';

  @override
  String get conflictAlreadyResolved =>
      'This task was already finished on another device.';

  @override
  String get conflictEntityDeleted =>
      'This task was deleted on another device.';

  @override
  String get conflictInvalidTransition =>
      'That action isn\'t possible for this task anymore.';

  @override
  String get conflictGeneric =>
      'This changed on another device. We kept the latest version.';

  @override
  String get permissionNotificationsDenied =>
      'Notifications are off, so reminders can\'t be shown.';

  @override
  String get permissionExactAlarmsDenied =>
      'Exact alarms are off, so reminders may arrive a few minutes late.';

  @override
  String get permissionMicrophoneDenied =>
      'Microphone access is needed to add tasks by voice.';

  @override
  String get permissionSpeechDenied =>
      'Speech recognition access is needed to add tasks by voice.';

  @override
  String get failureInvalidCredentials =>
      'That email and password don\'t match.';

  @override
  String get conflictEmailTaken =>
      'An account with this email already exists. Try signing in.';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Plan it. Do it. Learn from it.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get orDivider => 'or';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccountPrompt => 'New here?';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get sessionExpiredNotice =>
      'Your session ended. Please sign in again.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get displayNameLabel => 'Your name';

  @override
  String passwordHint(int min) {
    return 'At least $min characters';
  }

  @override
  String get registerButton => 'Create account';

  @override
  String get haveAccountPrompt => 'Already have an account?';

  @override
  String get signInLink => 'Sign in';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordIntro =>
      'Enter your account email and we\'ll send you a 6-digit code.';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String codeSentIntro(String email) {
    return 'If an account exists for $email, we\'ve sent a 6-digit code. It expires in 15 minutes.';
  }

  @override
  String get resetCodeLabel => '6-digit code';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get resetPasswordButton => 'Reset password';

  @override
  String get changeEmailButton => 'Use a different email';

  @override
  String get passwordResetDone =>
      'Your password was changed and you\'ve been signed out everywhere. Sign in with your new password.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get errorEmailEmpty => 'Enter your email.';

  @override
  String get errorEmailInvalid => 'Enter a valid email address.';

  @override
  String get errorPasswordEmpty => 'Enter your password.';

  @override
  String errorPasswordTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String errorPasswordTooLong(int max) {
    return 'Use at most $max characters.';
  }

  @override
  String get errorDisplayNameEmpty => 'Enter your name.';

  @override
  String errorDisplayNameTooLong(int max) {
    return 'Use at most $max characters.';
  }

  @override
  String get errorResetCodeInvalid => 'Enter the 6-digit code from the email.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNameLabel => 'Name';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profileTimeZoneLabel => 'Time zone';

  @override
  String get saveButton => 'Save';

  @override
  String get profileSaved => 'Profile updated.';

  @override
  String get subscriptionTitle => 'Pro';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get addTask => 'Add task';

  @override
  String get anyTime => 'Any time';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get markDone => 'Mark as done';

  @override
  String get doneWithDuration => 'Done, enter time';

  @override
  String get postpone => 'Postpone';

  @override
  String get skip => 'Skip';

  @override
  String get reopen => 'Reopen';

  @override
  String get moreActions => 'More actions';

  @override
  String get dayToday => 'Today';

  @override
  String get dayTomorrow => 'Tomorrow';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String progressDone(int done, int total) {
    return '$done of $total done';
  }

  @override
  String plannedTime(String duration) {
    return '$duration planned';
  }

  @override
  String get nextTaskLabel => 'Next up';

  @override
  String get quickAddHint => 'Add a task for today…';

  @override
  String get quickAddMoreOptions => 'More options';

  @override
  String get emptyToday =>
      'Nothing planned for today. Add a task to get started.';

  @override
  String get emptyDay => 'Nothing planned for this day.';

  @override
  String sectionToDo(int count) {
    return 'To do · $count';
  }

  @override
  String sectionDone(int count) {
    return 'Done · $count';
  }

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String completeTaskNamed(String title) {
    return 'Mark $title as done';
  }

  @override
  String reopenTaskNamed(String title) {
    return 'Reopen $title';
  }

  @override
  String get repeatingTask => 'Repeats';

  @override
  String get postponedTask => 'Postponed';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusDue => 'Now';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusMissed => 'Missed';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusCompleted => 'Done';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get skipReasonNoTime => 'No time';

  @override
  String get skipReasonNotNeeded => 'Not needed anymore';

  @override
  String get skipReasonTooTired => 'Too tired';

  @override
  String get skipReasonForgot => 'Forgot';

  @override
  String get skipReasonOther => 'Other reason';

  @override
  String get skipWhy => 'Why are you skipping it?';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String repeatEveryNDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryNWeeksOn(int count, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks on $days',
      one: 'Every week on $days',
    );
    return '$_temp0';
  }

  @override
  String repeatEveryNMonthsOnDay(int count, int day) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months on day $day',
      one: 'Monthly on day $day',
    );
    return '$_temp0';
  }

  @override
  String everyNDaysLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String everyNWeeksLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count weeks',
      one: 'Every week',
    );
    return '$_temp0';
  }

  @override
  String everyNMonthsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count months',
      one: 'Every month',
    );
    return '$_temp0';
  }

  @override
  String repeatTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return '$_temp0';
  }

  @override
  String get repeatEndsNever => 'Never';

  @override
  String get repeatEndsOnDate => 'On a date';

  @override
  String get repeatEndsAfterCount => 'After a number of times';

  @override
  String get reminderNone => 'None';

  @override
  String get reminderAtStart => 'At start time';

  @override
  String reminderBefore(String duration) {
    return '$duration before';
  }

  @override
  String get reminderNeedsTime => 'Set a start time to get a reminder.';

  @override
  String get newTaskTitle => 'New task';

  @override
  String get editTaskTitle => 'Edit task';

  @override
  String get editorTitleLabel => 'Title';

  @override
  String get editorTitleHint => 'What do you want to do?';

  @override
  String get editorWhen => 'When';

  @override
  String get editorDate => 'Date';

  @override
  String get editorSetTime => 'Set a start time';

  @override
  String get editorStartTime => 'Start time';

  @override
  String editorChangesApplyFrom(String date) {
    return 'Schedule changes apply from $date. Earlier days keep their history.';
  }

  @override
  String get editorDuration => 'Expected duration';

  @override
  String get editorRepeat => 'Repeat';

  @override
  String get editorRepeatEnds => 'Ends';

  @override
  String get editorReminder => 'Reminder';

  @override
  String get editorPriority => 'Priority';

  @override
  String get editorCategory => 'Category';

  @override
  String get editorNotes => 'Notes';

  @override
  String get editorNotesHint => 'Details, links, anything useful';

  @override
  String get categoryNone => 'None';

  @override
  String get decrease => 'Decrease';

  @override
  String get increase => 'Increase';

  @override
  String get errorTitleRequired => 'Give the task a title.';

  @override
  String errorTitleTooLong(int max) {
    return 'Use at most $max characters.';
  }

  @override
  String errorNotesTooLong(int max) {
    return 'Use at most $max characters.';
  }

  @override
  String get errorDateInPast => 'Pick today or a later date.';

  @override
  String get errorDurationRange =>
      'Choose a duration between 1 minute and 24 hours.';

  @override
  String get errorUntilBeforeStart =>
      'The end date must be on or after the start date.';

  @override
  String errorCountRange(int max) {
    return 'Repeat between 1 and $max times.';
  }

  @override
  String get errorIntervalRange => 'That repeat interval is too long.';

  @override
  String get errorPostponeInPast => 'Pick a time later than now.';

  @override
  String get errorPostponeUnchanged => 'That is when it is already planned.';

  @override
  String get errorCategoryNameRequired => 'Give the category a name.';

  @override
  String get occurrenceGone =>
      'This task no longer exists. It may have been deleted on another device.';

  @override
  String get postponeLaterToday => 'In 1 hour';

  @override
  String get postponeTomorrow => 'Tomorrow';

  @override
  String get postponePick => 'Pick a date and time';

  @override
  String postponedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Postponed $count times',
      one: 'Postponed once',
    );
    return '$_temp0';
  }

  @override
  String completedTook(String duration) {
    return 'Done · took $duration';
  }

  @override
  String get completedUnmeasured => 'Done · time not measured';

  @override
  String get actualDurationTitle => 'How long did it take?';

  @override
  String get noteTitle => 'Note';

  @override
  String get noteHint => 'How did it go?';

  @override
  String get noteEmpty => 'Add a note';

  @override
  String get cancelOccurrence => 'Cancel this one';

  @override
  String get endRepeat => 'Stop repeating';

  @override
  String get endRepeatTitle => 'Stop repeating?';

  @override
  String get endRepeatMessage =>
      'Today stays on your list. Future days are removed; anything you already did or changed is kept.';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String get deleteTaskMessage =>
      'The task is removed from this device and, once synced, from your account.';

  @override
  String get deleteRepeatingTaskMessage =>
      'All days of this repeating task are removed, including their history.';

  @override
  String get errorAlreadyResolved =>
      'This task is already finished. Reopen it to change when it happens.';

  @override
  String reminderNotificationBody(String time) {
    return 'Starts at $time';
  }

  @override
  String snoozeNotificationBody(String time) {
    return 'Snoozed reminder · planned for $time';
  }

  @override
  String get reminderActionDone => 'Done';

  @override
  String get reminderActionSnooze => 'Snooze 10 min';

  @override
  String get reminderChannelName => 'Task reminders';

  @override
  String get reminderChannelDescription =>
      'Reminders shortly before a planned task starts';

  @override
  String get updatesChannelName => 'Account and updates';

  @override
  String get updatesChannelDescription =>
      'Account, subscription and insight messages';

  @override
  String get remindersOffBanner => 'Reminders are off for this app.';

  @override
  String get turnOnAction => 'Turn on';

  @override
  String get openSettingsAction => 'Open settings';

  @override
  String get allowAction => 'Allow';

  @override
  String get notificationSettingsTitle => 'Notifications';

  @override
  String get remindersSectionTitle => 'Task reminders';

  @override
  String get remindersSwitchTitle => 'Remind me before tasks';

  @override
  String get remindersSwitchSubtitle => 'Uses the reminder set on each task';

  @override
  String get systemNotificationsAllowed => 'Notifications are allowed';

  @override
  String get systemNotificationsNotAsked =>
      'Allow notifications to get reminders';

  @override
  String get exactAlarmsTitle => 'Exact reminder times';

  @override
  String get pushSectionTitle => 'Other notifications';

  @override
  String get pushInsightsTitle => 'Insights';

  @override
  String get pushInsightsSubtitle => 'Suggestions based on how your tasks go';

  @override
  String get pushWeeklySummaryTitle => 'Weekly summary';

  @override
  String get pushWeeklySummarySubtitle => 'Your week at a glance, every Monday';

  @override
  String get pushAlwaysDeliveredNote =>
      'Account, security and subscription messages are always sent.';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get startAction => 'Start';

  @override
  String get pauseAction => 'Pause';

  @override
  String get resumeAction => 'Resume';

  @override
  String get timerRunningLabel => 'Working on';

  @override
  String get timerPausedLabel => 'Paused';

  @override
  String timeLeft(String duration) {
    return '$duration left';
  }

  @override
  String timeOver(String duration) {
    return '$duration over plan';
  }

  @override
  String trackedOfPlanned(String tracked, String planned) {
    return '$tracked of $planned';
  }

  @override
  String elapsedSemantics(String duration) {
    return '$duration tracked so far';
  }

  @override
  String autoPausedNotice(String title) {
    return 'Paused “$title”';
  }

  @override
  String get longSessionTitle => 'That was a long one';

  @override
  String longSessionMessage(String duration) {
    return 'The timer shows $duration. Was it left running?';
  }

  @override
  String longSessionKeep(String duration) {
    return 'Keep $duration';
  }

  @override
  String get longSessionEnter => 'Enter the actual time';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String dateRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get metricCompletion => 'Completed';

  @override
  String get nothingDueYet => 'Nothing due yet';

  @override
  String get noValue => '–';

  @override
  String deltaUp(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: 'Up $points points on the previous period',
      one: 'Up 1 point on the previous period',
    );
    return '$_temp0';
  }

  @override
  String deltaDown(int points) {
    String _temp0 = intl.Intl.pluralLogic(
      points,
      locale: localeName,
      other: 'Down $points points on the previous period',
      one: 'Down 1 point on the previous period',
    );
    return '$_temp0';
  }

  @override
  String get deltaSame => 'Same as the previous period';

  @override
  String get metricTracked => 'Time tracked';

  @override
  String ofPlanned(String duration) {
    return 'of $duration planned';
  }

  @override
  String get metricOnTime => 'Started on time';

  @override
  String get noTimedStarts => 'No timed starts yet';

  @override
  String get typicallyOnTime => 'Usually right on time';

  @override
  String typicallyLate(String duration) {
    return 'Usually $duration late';
  }

  @override
  String typicallyEarly(String duration) {
    return 'Usually $duration early';
  }

  @override
  String get metricEstimates => 'Time vs plan';

  @override
  String get noMeasurements => 'Use the timer to compare';

  @override
  String get estimateAccurate => 'Close to plan';

  @override
  String estimateLonger(String percent) {
    return 'Took $percent longer than planned';
  }

  @override
  String estimateShorter(String percent) {
    return 'Took $percent less than planned';
  }

  @override
  String estimateBasis(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Based on $count timed tasks',
      one: 'Based on 1 timed task',
    );
    return '$_temp0';
  }

  @override
  String get metricPostponed => 'Postponed';

  @override
  String postponementsValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count times in total',
      one: 'Moved once',
      zero: 'Nothing moved',
    );
    return '$_temp0';
  }

  @override
  String get chartOutcomesTitle => 'Done, skipped and missed';

  @override
  String get chartTapHint => 'Tap a day to see it';

  @override
  String get chartTimeTitle => 'Planned vs tracked time';

  @override
  String get outcomeDone => 'Done';

  @override
  String get outcomeSkipped => 'Skipped';

  @override
  String get outcomeMissed => 'Missed';

  @override
  String get outcomeOpen => 'To do';

  @override
  String get legendPlanned => 'Planned';

  @override
  String get legendTracked => 'Tracked';

  @override
  String get legendTookDone => 'Time it took';

  @override
  String get legendPlannedLine => 'Planned time';

  @override
  String barOutcomeSemantics(
    String date,
    int done,
    int skipped,
    int missed,
    int open,
  ) {
    return '$date: $done done, $skipped skipped, $missed missed, $open to do';
  }

  @override
  String barTimeSemantics(String date, String planned, String tracked) {
    return '$date: $planned planned, $tracked tracked';
  }

  @override
  String historyBarSemantics(
    String date,
    String outcome,
    String actual,
    String planned,
  ) {
    return '$date: $outcome, took $actual, planned $planned';
  }

  @override
  String get notMeasured => 'not measured';

  @override
  String get planVsActualTitle => 'Plan vs actual';

  @override
  String plannedVsActual(String planned, String actual) {
    return '$planned planned, $actual';
  }

  @override
  String get startedOnTime => 'Started on time';

  @override
  String startedLate(String duration) {
    return 'Started $duration late';
  }

  @override
  String startedEarly(String duration) {
    return 'Started $duration early';
  }

  @override
  String get byActivityTitle => 'By activity';

  @override
  String activityRowSubtitle(int done, int total, String tracked) {
    return '$done of $total done · $tracked tracked';
  }

  @override
  String get analyticsEmptyDay => 'Nothing was planned for this day.';

  @override
  String get analyticsEmptyWeek => 'Nothing was planned for this week.';

  @override
  String get analyticsEmptyMonth => 'Nothing was planned for this month.';

  @override
  String historyLimited(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Your plan includes the last $days days of history.',
      one: 'Your plan includes today\'s history only.',
    );
    return '$_temp0';
  }

  @override
  String get seePlans => 'See plans';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityNotFound =>
      'This activity has no history yet, or it was deleted.';

  @override
  String activitySince(String date) {
    return 'Since $date';
  }

  @override
  String get streakCurrent => 'Streak';

  @override
  String streakValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in a row',
      one: '1 in a row',
      zero: 'None yet',
    );
    return '$_temp0';
  }

  @override
  String streakBest(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Best: $count in a row',
      zero: 'Best: none yet',
    );
    return '$_temp0';
  }

  @override
  String get historyChartTitle => 'Recent occurrences';

  @override
  String historyChartSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The last $count occurrences',
      one: 'The last occurrence',
    );
    return '$_temp0';
  }

  @override
  String get suggestionTitle => 'Suggested duration';

  @override
  String suggestionBody(int count, String suggested, String current) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Your last $count timed sessions took about $suggested. It is planned for $current.',
    );
    return '$_temp0';
  }

  @override
  String suggestionApply(String duration) {
    return 'Plan $duration from now on';
  }

  @override
  String get suggestionApplied => 'Expected duration updated';

  @override
  String get suggestionLocked =>
      'Duration suggestions are included with advanced analytics.';

  @override
  String get activityInsights => 'Activity insights';

  @override
  String get activityInsightsSubtitle => 'Streaks and how long it really takes';

  @override
  String get addByVoice => 'Add by voice';

  @override
  String get voiceTitle => 'Add by voice';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceExample =>
      'Try: “Run tomorrow at 7 for 30 minutes”, “Pay rent on the 1st of every month”';

  @override
  String get voiceExampleShort => 'Call mom tomorrow at 6 pm';

  @override
  String get voiceStop => 'Stop listening';

  @override
  String voiceHeard(String text) {
    return '“$text”';
  }

  @override
  String get voiceUnderstood => 'Here\'s what I understood';

  @override
  String get voiceOnlyTitle =>
      'Only the title was understood. You can add the rest in the next step.';

  @override
  String get voiceContinue => 'Review and save';

  @override
  String get voiceTryAgain => 'Try again';

  @override
  String get voiceUnsupported =>
      'Speech recognition isn\'t available on this device. You can type the task instead.';

  @override
  String get voiceNothingHeard =>
      'Nothing was heard. Try again a little closer to the microphone.';

  @override
  String get voiceNetwork =>
      'Speech recognition needs an internet connection on this device.';

  @override
  String get voiceBusy => 'The microphone is being used by another app.';

  @override
  String get voiceFailed => 'Something went wrong while listening. Try again.';

  @override
  String get voiceTypeInstead => 'Or type it';

  @override
  String get voiceUnderstand => 'Understand';

  @override
  String voiceDraftBanner(String text) {
    return 'From what you said: “$text”. Check the details, then save.';
  }

  @override
  String get prefillWhen => 'When';

  @override
  String get prefillRepeats => 'Repeats';

  @override
  String get prefillCategory => 'Category';

  @override
  String get prefillNotSet => 'Not set';

  @override
  String get subscriptionHeadline => 'Plan more. Learn more.';

  @override
  String get subscriptionSubheadline =>
      'Pro removes the limits and adds deeper insights into how your time really goes.';

  @override
  String get planFree => 'Free';

  @override
  String get planPro => 'Pro';

  @override
  String get planUnlimited => 'Unlimited';

  @override
  String get planActiveTasks => 'Active tasks';

  @override
  String get planRepeatingTasks => 'Repeating tasks';

  @override
  String get planEveryFewDays => 'Repeat every few days or weeks';

  @override
  String get planAnalyticsHistory => 'Analytics history';

  @override
  String get planAllHistory => 'All';

  @override
  String planDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get planDurationSuggestions => 'Duration suggestions';

  @override
  String get planIncluded => 'Included';

  @override
  String get planNotIncluded => 'Not included';

  @override
  String offerAnnual(String price) {
    return '$price per year';
  }

  @override
  String offerMonthly(String price) {
    return '$price per month';
  }

  @override
  String offerPerMonth(String price) {
    return '$price a month';
  }

  @override
  String offerTrial(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days-day free trial',
      one: '1-day free trial',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionStartTrial => 'Start free trial';

  @override
  String get subscriptionSubscribe => 'Subscribe';

  @override
  String get subscriptionRestore => 'Restore purchases';

  @override
  String get subscriptionUnavailable =>
      'Purchases aren\'t available in this version of the app.';

  @override
  String get subscriptionLegal =>
      'Payment is charged to your App Store or Google Play account. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period; you can manage or cancel it in your store account settings. A free trial converts to a paid subscription when it ends unless cancelled.';

  @override
  String get linkTerms => 'Terms of use';

  @override
  String get linkPrivacy => 'Privacy policy';

  @override
  String get subscriptionWelcome => 'Welcome to Pro!';

  @override
  String get subscriptionNothingToRestore =>
      'No purchases to restore for this store account.';

  @override
  String get subscriptionYouArePro => 'You\'re on Pro';

  @override
  String get subscriptionConfirming =>
      'Confirming your purchase with our server…';

  @override
  String get subscriptionManage => 'Manage subscription';

  @override
  String get statusActive => 'Your subscription is active.';

  @override
  String statusRenews(String date) {
    return 'Renews on $date.';
  }

  @override
  String statusEnds(String date) {
    return 'Ends on $date. It won\'t renew.';
  }

  @override
  String statusTrialEnds(String date) {
    return 'Free trial until $date.';
  }

  @override
  String get statusBillingIssue => 'There\'s a problem with your payment.';

  @override
  String get statusBillingIssueHelp =>
      'Update your payment method in your store account to keep Pro.';

  @override
  String get purchasePending =>
      'Your purchase is waiting for approval. Pro unlocks as soon as it goes through.';

  @override
  String get purchaseNotAllowed => 'Purchases are turned off on this device.';

  @override
  String get entitlementAdvancedRecurrence =>
      'Repeating every few days or weeks is part of Pro.';

  @override
  String get entitlementAdvancedAnalytics => 'This is part of Pro.';

  @override
  String limitActiveSeries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Your plan includes $count active tasks. End one or upgrade to add more.',
      one: 'Your plan includes 1 active task. End one or upgrade to add more.',
    );
    return '$_temp0';
  }

  @override
  String limitRecurringSeries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your plan includes $count repeating tasks.',
      one: 'Your plan includes 1 repeating task.',
    );
    return '$_temp0';
  }

  @override
  String limitVoicePerMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You\'ve used your $count voice entries this month.',
      one: 'You\'ve used your 1 voice entry this month.',
    );
    return '$_temp0';
  }

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncStatusUpToDate => 'All changes synced';

  @override
  String syncStatusPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '1 change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusOffline => 'Offline. Changes are saved on this device.';

  @override
  String get syncStatusSyncing => 'Syncing…';

  @override
  String get syncStatusFailed => 'Last sync didn\'t finish';

  @override
  String get syncStatusNotYet => 'Not synced yet';

  @override
  String syncLastSynced(String time) {
    return 'Last synced $time';
  }

  @override
  String get syncNowAction => 'Sync now';

  @override
  String get syncDoneMessage => 'Everything is up to date';

  @override
  String get syncOfflineExplanation =>
      'You\'re offline. Everything you do is saved on this device and syncs when you\'re back online.';

  @override
  String get syncExplanation =>
      'Your tasks are saved on this device first and synced with your account in the background.';

  @override
  String get syncIssuesTitle => 'Changes that couldn\'t sync';

  @override
  String get syncIssueDismiss => 'Dismiss';

  @override
  String get syncIssueDismissAll => 'Dismiss all';

  @override
  String get syncIssueUnnamedTask => 'A task';

  @override
  String get syncIssueUnnamedCategory => 'A category';

  @override
  String get syncIssueUnnamedOther => 'A change';

  @override
  String get syncIssueDeleted =>
      'Deleted on another device. Your change was discarded.';

  @override
  String get syncIssueConflict =>
      'Changed on another device. That version was kept.';

  @override
  String get syncIssuePlan =>
      'Not included in your current plan. Your change was discarded.';

  @override
  String get syncIssueInvalid => 'The server couldn\'t accept this change.';

  @override
  String get syncIssueFailed => 'This change kept failing and was discarded.';

  @override
  String get syncIssueOther => 'The server refused this change.';

  @override
  String syncIssueCode(String code) {
    return 'Code $code';
  }
}
