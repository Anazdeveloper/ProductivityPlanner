import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Working app name shown by the OS task switcher.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get appTitle;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get tabPlanner;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionGoToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to Today'**
  String get actionGoToToday;

  /// No description provided for @notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist.'**
  String get notFoundMessage;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline or the server can\'t be reached. Your changes are saved on this device.'**
  String get failureNetwork;

  /// No description provided for @failureUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Please sign in again.'**
  String get failureUnauthenticated;

  /// No description provided for @failureForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to that.'**
  String get failureForbidden;

  /// No description provided for @failureValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields.'**
  String get failureValidation;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'That item doesn\'t exist anymore.'**
  String get failureNotFound;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again.'**
  String get failureServer;

  /// No description provided for @failureDatabase.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save that on this device. Please try again.'**
  String get failureDatabase;

  /// No description provided for @failureEntitlementRequired.
  ///
  /// In en, this message translates to:
  /// **'This is a Premium feature.'**
  String get failureEntitlementRequired;

  /// No description provided for @failureLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your plan\'s limit. Upgrade to add more.'**
  String get failureLimitReached;

  /// No description provided for @failureUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something unexpected happened. Please try again.'**
  String get failureUnexpected;

  /// No description provided for @conflictAlreadyResolved.
  ///
  /// In en, this message translates to:
  /// **'This task was already finished on another device.'**
  String get conflictAlreadyResolved;

  /// No description provided for @conflictEntityDeleted.
  ///
  /// In en, this message translates to:
  /// **'This task was deleted on another device.'**
  String get conflictEntityDeleted;

  /// No description provided for @conflictInvalidTransition.
  ///
  /// In en, this message translates to:
  /// **'That action isn\'t possible for this task anymore.'**
  String get conflictInvalidTransition;

  /// No description provided for @conflictGeneric.
  ///
  /// In en, this message translates to:
  /// **'This changed on another device. We kept the latest version.'**
  String get conflictGeneric;

  /// No description provided for @permissionNotificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off, so reminders can\'t be shown.'**
  String get permissionNotificationsDenied;

  /// No description provided for @permissionExactAlarmsDenied.
  ///
  /// In en, this message translates to:
  /// **'Exact alarms are off, so reminders may arrive a few minutes late.'**
  String get permissionExactAlarmsDenied;

  /// No description provided for @permissionMicrophoneDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to add tasks by voice.'**
  String get permissionMicrophoneDenied;

  /// No description provided for @permissionSpeechDenied.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition access is needed to add tasks by voice.'**
  String get permissionSpeechDenied;

  /// No description provided for @failureInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'That email and password don\'t match.'**
  String get failureInvalidCredentials;

  /// No description provided for @conflictEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try signing in.'**
  String get conflictEmailTaken;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan it. Do it. Learn from it.'**
  String get signInSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get noAccountPrompt;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountLink;

  /// No description provided for @sessionExpiredNotice.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Please sign in again.'**
  String get sessionExpiredNotice;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get displayNameLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters'**
  String passwordHint(int min);

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccountPrompt;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email and we\'ll send you a 6-digit code.'**
  String get forgotPasswordIntro;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @codeSentIntro.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, we\'ve sent a 6-digit code. It expires in 15 minutes.'**
  String codeSentIntro(String email);

  /// No description provided for @resetCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get resetCodeLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordButton;

  /// No description provided for @changeEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get changeEmailButton;

  /// No description provided for @passwordResetDone.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed and you\'ve been signed out everywhere. Sign in with your new password.'**
  String get passwordResetDone;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @errorEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email.'**
  String get errorEmailEmpty;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get errorPasswordEmpty;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String errorPasswordTooShort(int min);

  /// No description provided for @errorPasswordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most {max} characters.'**
  String errorPasswordTooLong(int max);

  /// No description provided for @errorDisplayNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get errorDisplayNameEmpty;

  /// No description provided for @errorDisplayNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most {max} characters.'**
  String errorDisplayNameTooLong(int max);

  /// No description provided for @errorResetCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from the email.'**
  String get errorResetCodeInvalid;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileNameLabel;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profileTimeZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get profileTimeZoneLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileSaved;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get subscriptionTitle;

  /// No description provided for @signOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @anyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get anyTime;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markDone;

  /// No description provided for @doneWithDuration.
  ///
  /// In en, this message translates to:
  /// **'Done, enter time'**
  String get doneWithDuration;

  /// No description provided for @postpone.
  ///
  /// In en, this message translates to:
  /// **'Postpone'**
  String get postpone;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @moreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActions;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dayTomorrow;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @progressDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String progressDone(int done, int total);

  /// No description provided for @plannedTime.
  ///
  /// In en, this message translates to:
  /// **'{duration} planned'**
  String plannedTime(String duration);

  /// No description provided for @nextTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get nextTaskLabel;

  /// No description provided for @quickAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a task for today…'**
  String get quickAddHint;

  /// No description provided for @quickAddMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get quickAddMoreOptions;

  /// No description provided for @emptyToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for today. Add a task to get started.'**
  String get emptyToday;

  /// No description provided for @emptyDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for this day.'**
  String get emptyDay;

  /// No description provided for @sectionToDo.
  ///
  /// In en, this message translates to:
  /// **'To do · {count}'**
  String sectionToDo(int count);

  /// No description provided for @sectionDone.
  ///
  /// In en, this message translates to:
  /// **'Done · {count}'**
  String sectionDone(int count);

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// No description provided for @completeTaskNamed.
  ///
  /// In en, this message translates to:
  /// **'Mark {title} as done'**
  String completeTaskNamed(String title);

  /// No description provided for @reopenTaskNamed.
  ///
  /// In en, this message translates to:
  /// **'Reopen {title}'**
  String reopenTaskNamed(String title);

  /// No description provided for @repeatingTask.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeatingTask;

  /// No description provided for @postponedTask.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get postponedTask;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get statusDue;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get statusMissed;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusCompleted;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @skipReasonNoTime.
  ///
  /// In en, this message translates to:
  /// **'No time'**
  String get skipReasonNoTime;

  /// No description provided for @skipReasonNotNeeded.
  ///
  /// In en, this message translates to:
  /// **'Not needed anymore'**
  String get skipReasonNotNeeded;

  /// No description provided for @skipReasonTooTired.
  ///
  /// In en, this message translates to:
  /// **'Too tired'**
  String get skipReasonTooTired;

  /// No description provided for @skipReasonForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot'**
  String get skipReasonForgot;

  /// No description provided for @skipReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get skipReasonOther;

  /// No description provided for @skipWhy.
  ///
  /// In en, this message translates to:
  /// **'Why are you skipping it?'**
  String get skipWhy;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @repeatEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String repeatEveryNDays(int count);

  /// No description provided for @repeatEveryNWeeksOn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week on {days}} other{Every {count} weeks on {days}}}'**
  String repeatEveryNWeeksOn(int count, String days);

  /// No description provided for @repeatEveryNMonthsOnDay.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Monthly on day {day}} other{Every {count} months on day {day}}}'**
  String repeatEveryNMonthsOnDay(int count, int day);

  /// No description provided for @everyNDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String everyNDaysLabel(int count);

  /// No description provided for @everyNWeeksLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every week} other{Every {count} weeks}}'**
  String everyNWeeksLabel(int count);

  /// No description provided for @everyNMonthsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every month} other{Every {count} months}}'**
  String everyNMonthsLabel(int count);

  /// No description provided for @repeatTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time} other{{count} times}}'**
  String repeatTimes(int count);

  /// No description provided for @repeatEndsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get repeatEndsNever;

  /// No description provided for @repeatEndsOnDate.
  ///
  /// In en, this message translates to:
  /// **'On a date'**
  String get repeatEndsOnDate;

  /// No description provided for @repeatEndsAfterCount.
  ///
  /// In en, this message translates to:
  /// **'After a number of times'**
  String get repeatEndsAfterCount;

  /// No description provided for @reminderNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get reminderNone;

  /// No description provided for @reminderAtStart.
  ///
  /// In en, this message translates to:
  /// **'At start time'**
  String get reminderAtStart;

  /// No description provided for @reminderBefore.
  ///
  /// In en, this message translates to:
  /// **'{duration} before'**
  String reminderBefore(String duration);

  /// No description provided for @reminderNeedsTime.
  ///
  /// In en, this message translates to:
  /// **'Set a start time to get a reminder.'**
  String get reminderNeedsTime;

  /// No description provided for @newTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get newTaskTitle;

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTaskTitle;

  /// No description provided for @editorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editorTitleLabel;

  /// No description provided for @editorTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get editorTitleHint;

  /// No description provided for @editorWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get editorWhen;

  /// No description provided for @editorDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get editorDate;

  /// No description provided for @editorSetTime.
  ///
  /// In en, this message translates to:
  /// **'Set a start time'**
  String get editorSetTime;

  /// No description provided for @editorStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get editorStartTime;

  /// No description provided for @editorChangesApplyFrom.
  ///
  /// In en, this message translates to:
  /// **'Schedule changes apply from {date}. Earlier days keep their history.'**
  String editorChangesApplyFrom(String date);

  /// No description provided for @editorDuration.
  ///
  /// In en, this message translates to:
  /// **'Expected duration'**
  String get editorDuration;

  /// No description provided for @editorRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get editorRepeat;

  /// No description provided for @editorRepeatEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get editorRepeatEnds;

  /// No description provided for @editorReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get editorReminder;

  /// No description provided for @editorPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get editorPriority;

  /// No description provided for @editorCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get editorCategory;

  /// No description provided for @editorNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get editorNotes;

  /// No description provided for @editorNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Details, links, anything useful'**
  String get editorNotesHint;

  /// No description provided for @categoryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get categoryNone;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @errorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the task a title.'**
  String get errorTitleRequired;

  /// No description provided for @errorTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most {max} characters.'**
  String errorTitleTooLong(int max);

  /// No description provided for @errorNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use at most {max} characters.'**
  String errorNotesTooLong(int max);

  /// No description provided for @errorDateInPast.
  ///
  /// In en, this message translates to:
  /// **'Pick today or a later date.'**
  String get errorDateInPast;

  /// No description provided for @errorDurationRange.
  ///
  /// In en, this message translates to:
  /// **'Choose a duration between 1 minute and 24 hours.'**
  String get errorDurationRange;

  /// No description provided for @errorUntilBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end date must be on or after the start date.'**
  String get errorUntilBeforeStart;

  /// No description provided for @errorCountRange.
  ///
  /// In en, this message translates to:
  /// **'Repeat between 1 and {max} times.'**
  String errorCountRange(int max);

  /// No description provided for @errorIntervalRange.
  ///
  /// In en, this message translates to:
  /// **'That repeat interval is too long.'**
  String get errorIntervalRange;

  /// No description provided for @errorPostponeInPast.
  ///
  /// In en, this message translates to:
  /// **'Pick a time later than now.'**
  String get errorPostponeInPast;

  /// No description provided for @errorPostponeUnchanged.
  ///
  /// In en, this message translates to:
  /// **'That is when it is already planned.'**
  String get errorPostponeUnchanged;

  /// No description provided for @errorCategoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the category a name.'**
  String get errorCategoryNameRequired;

  /// No description provided for @occurrenceGone.
  ///
  /// In en, this message translates to:
  /// **'This task no longer exists. It may have been deleted on another device.'**
  String get occurrenceGone;

  /// No description provided for @postponeLaterToday.
  ///
  /// In en, this message translates to:
  /// **'In 1 hour'**
  String get postponeLaterToday;

  /// No description provided for @postponeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get postponeTomorrow;

  /// No description provided for @postponePick.
  ///
  /// In en, this message translates to:
  /// **'Pick a date and time'**
  String get postponePick;

  /// No description provided for @postponedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Postponed once} other{Postponed {count} times}}'**
  String postponedTimes(int count);

  /// No description provided for @completedTook.
  ///
  /// In en, this message translates to:
  /// **'Done · took {duration}'**
  String completedTook(String duration);

  /// No description provided for @completedUnmeasured.
  ///
  /// In en, this message translates to:
  /// **'Done · time not measured'**
  String get completedUnmeasured;

  /// No description provided for @actualDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'How long did it take?'**
  String get actualDurationTitle;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteTitle;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get noteHint;

  /// No description provided for @noteEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get noteEmpty;

  /// No description provided for @cancelOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Cancel this one'**
  String get cancelOccurrence;

  /// No description provided for @endRepeat.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating'**
  String get endRepeat;

  /// No description provided for @endRepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop repeating?'**
  String get endRepeatTitle;

  /// No description provided for @endRepeatMessage.
  ///
  /// In en, this message translates to:
  /// **'Today stays on your list. Future days are removed; anything you already did or changed is kept.'**
  String get endRepeatMessage;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'The task is removed from this device and, once synced, from your account.'**
  String get deleteTaskMessage;

  /// No description provided for @deleteRepeatingTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'All days of this repeating task are removed, including their history.'**
  String get deleteRepeatingTaskMessage;

  /// No description provided for @errorAlreadyResolved.
  ///
  /// In en, this message translates to:
  /// **'This task is already finished. Reopen it to change when it happens.'**
  String get errorAlreadyResolved;

  /// Reminder notification body; time is the task start, e.g. 7:00 PM
  ///
  /// In en, this message translates to:
  /// **'Starts at {time}'**
  String reminderNotificationBody(String time);

  /// Snoozed reminder body
  ///
  /// In en, this message translates to:
  /// **'Snoozed reminder · planned for {time}'**
  String snoozeNotificationBody(String time);

  /// Notification button: mark the task done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reminderActionDone;

  /// Notification button: remind again in 10 minutes
  ///
  /// In en, this message translates to:
  /// **'Snooze 10 min'**
  String get reminderActionSnooze;

  /// Android notification channel name
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get reminderChannelName;

  /// Android notification channel description
  ///
  /// In en, this message translates to:
  /// **'Reminders shortly before a planned task starts'**
  String get reminderChannelDescription;

  /// Android channel for server messages
  ///
  /// In en, this message translates to:
  /// **'Account and updates'**
  String get updatesChannelName;

  /// Android channel description
  ///
  /// In en, this message translates to:
  /// **'Account, subscription and insight messages'**
  String get updatesChannelDescription;

  /// Today banner when notification permission is missing
  ///
  /// In en, this message translates to:
  /// **'Reminders are off for this app.'**
  String get remindersOffBanner;

  /// No description provided for @turnOnAction.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOnAction;

  /// No description provided for @openSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsAction;

  /// No description provided for @allowAction.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allowAction;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationSettingsTitle;

  /// No description provided for @remindersSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Task reminders'**
  String get remindersSectionTitle;

  /// No description provided for @remindersSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me before tasks'**
  String get remindersSwitchTitle;

  /// No description provided for @remindersSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses the reminder set on each task'**
  String get remindersSwitchSubtitle;

  /// No description provided for @systemNotificationsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Notifications are allowed'**
  String get systemNotificationsAllowed;

  /// No description provided for @systemNotificationsNotAsked.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications to get reminders'**
  String get systemNotificationsNotAsked;

  /// No description provided for @exactAlarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exact reminder times'**
  String get exactAlarmsTitle;

  /// No description provided for @pushSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Other notifications'**
  String get pushSectionTitle;

  /// No description provided for @pushInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get pushInsightsTitle;

  /// No description provided for @pushInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions based on how your tasks go'**
  String get pushInsightsSubtitle;

  /// No description provided for @pushWeeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get pushWeeklySummaryTitle;

  /// No description provided for @pushWeeklySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your week at a glance, every Monday'**
  String get pushWeeklySummarySubtitle;

  /// No description provided for @pushAlwaysDeliveredNote.
  ///
  /// In en, this message translates to:
  /// **'Account, security and subscription messages are always sent.'**
  String get pushAlwaysDeliveredNote;

  /// Settings list entry
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Start working on a task (timer)
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startAction;

  /// No description provided for @pauseAction.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseAction;

  /// No description provided for @resumeAction.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeAction;

  /// Label above the running task on Today
  ///
  /// In en, this message translates to:
  /// **'Working on'**
  String get timerRunningLabel;

  /// Label above a paused task on Today
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get timerPausedLabel;

  /// Remaining planned time
  ///
  /// In en, this message translates to:
  /// **'{duration} left'**
  String timeLeft(String duration);

  /// Time beyond the planned duration
  ///
  /// In en, this message translates to:
  /// **'{duration} over plan'**
  String timeOver(String duration);

  /// Tracked versus planned time
  ///
  /// In en, this message translates to:
  /// **'{tracked} of {planned}'**
  String trackedOfPlanned(String tracked, String planned);

  /// Screen reader label for the timer
  ///
  /// In en, this message translates to:
  /// **'{duration} tracked so far'**
  String elapsedSemantics(String duration);

  /// Snackbar after starting a task paused another
  ///
  /// In en, this message translates to:
  /// **'Paused “{title}”'**
  String autoPausedNotice(String title);

  /// No description provided for @longSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'That was a long one'**
  String get longSessionTitle;

  /// Asked before completing with an implausible tracked time
  ///
  /// In en, this message translates to:
  /// **'The timer shows {duration}. Was it left running?'**
  String longSessionMessage(String duration);

  /// Complete with the tracked time
  ///
  /// In en, this message translates to:
  /// **'Keep {duration}'**
  String longSessionKeep(String duration);

  /// No description provided for @longSessionEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter the actual time'**
  String get longSessionEnter;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String dateRange(String start, String end);

  /// No description provided for @metricCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get metricCompletion;

  /// No description provided for @nothingDueYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing due yet'**
  String get nothingDueYet;

  /// No description provided for @noValue.
  ///
  /// In en, this message translates to:
  /// **'–'**
  String get noValue;

  /// No description provided for @deltaUp.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{Up 1 point on the previous period} other{Up {points} points on the previous period}}'**
  String deltaUp(int points);

  /// No description provided for @deltaDown.
  ///
  /// In en, this message translates to:
  /// **'{points, plural, =1{Down 1 point on the previous period} other{Down {points} points on the previous period}}'**
  String deltaDown(int points);

  /// No description provided for @deltaSame.
  ///
  /// In en, this message translates to:
  /// **'Same as the previous period'**
  String get deltaSame;

  /// No description provided for @metricTracked.
  ///
  /// In en, this message translates to:
  /// **'Time tracked'**
  String get metricTracked;

  /// No description provided for @ofPlanned.
  ///
  /// In en, this message translates to:
  /// **'of {duration} planned'**
  String ofPlanned(String duration);

  /// No description provided for @metricOnTime.
  ///
  /// In en, this message translates to:
  /// **'Started on time'**
  String get metricOnTime;

  /// No description provided for @noTimedStarts.
  ///
  /// In en, this message translates to:
  /// **'No timed starts yet'**
  String get noTimedStarts;

  /// No description provided for @typicallyOnTime.
  ///
  /// In en, this message translates to:
  /// **'Usually right on time'**
  String get typicallyOnTime;

  /// No description provided for @typicallyLate.
  ///
  /// In en, this message translates to:
  /// **'Usually {duration} late'**
  String typicallyLate(String duration);

  /// No description provided for @typicallyEarly.
  ///
  /// In en, this message translates to:
  /// **'Usually {duration} early'**
  String typicallyEarly(String duration);

  /// No description provided for @metricEstimates.
  ///
  /// In en, this message translates to:
  /// **'Time vs plan'**
  String get metricEstimates;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Use the timer to compare'**
  String get noMeasurements;

  /// No description provided for @estimateAccurate.
  ///
  /// In en, this message translates to:
  /// **'Close to plan'**
  String get estimateAccurate;

  /// No description provided for @estimateLonger.
  ///
  /// In en, this message translates to:
  /// **'Took {percent} longer than planned'**
  String estimateLonger(String percent);

  /// No description provided for @estimateShorter.
  ///
  /// In en, this message translates to:
  /// **'Took {percent} less than planned'**
  String estimateShorter(String percent);

  /// No description provided for @estimateBasis.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Based on 1 timed task} other{Based on {count} timed tasks}}'**
  String estimateBasis(int count);

  /// No description provided for @metricPostponed.
  ///
  /// In en, this message translates to:
  /// **'Postponed'**
  String get metricPostponed;

  /// No description provided for @postponementsValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing moved} =1{Moved once} other{Moved {count} times in total}}'**
  String postponementsValue(int count);

  /// No description provided for @chartOutcomesTitle.
  ///
  /// In en, this message translates to:
  /// **'Done, skipped and missed'**
  String get chartOutcomesTitle;

  /// No description provided for @chartTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see it'**
  String get chartTapHint;

  /// No description provided for @chartTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Planned vs tracked time'**
  String get chartTimeTitle;

  /// No description provided for @outcomeDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get outcomeDone;

  /// No description provided for @outcomeSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get outcomeSkipped;

  /// No description provided for @outcomeMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get outcomeMissed;

  /// No description provided for @outcomeOpen.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get outcomeOpen;

  /// No description provided for @legendPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get legendPlanned;

  /// No description provided for @legendTracked.
  ///
  /// In en, this message translates to:
  /// **'Tracked'**
  String get legendTracked;

  /// No description provided for @legendTookDone.
  ///
  /// In en, this message translates to:
  /// **'Time it took'**
  String get legendTookDone;

  /// No description provided for @legendPlannedLine.
  ///
  /// In en, this message translates to:
  /// **'Planned time'**
  String get legendPlannedLine;

  /// No description provided for @barOutcomeSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}: {done} done, {skipped} skipped, {missed} missed, {open} to do'**
  String barOutcomeSemantics(
    String date,
    int done,
    int skipped,
    int missed,
    int open,
  );

  /// No description provided for @barTimeSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}: {planned} planned, {tracked} tracked'**
  String barTimeSemantics(String date, String planned, String tracked);

  /// No description provided for @historyBarSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}: {outcome}, took {actual}, planned {planned}'**
  String historyBarSemantics(
    String date,
    String outcome,
    String actual,
    String planned,
  );

  /// No description provided for @notMeasured.
  ///
  /// In en, this message translates to:
  /// **'not measured'**
  String get notMeasured;

  /// No description provided for @planVsActualTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan vs actual'**
  String get planVsActualTitle;

  /// No description provided for @plannedVsActual.
  ///
  /// In en, this message translates to:
  /// **'{planned} planned, {actual}'**
  String plannedVsActual(String planned, String actual);

  /// No description provided for @startedOnTime.
  ///
  /// In en, this message translates to:
  /// **'Started on time'**
  String get startedOnTime;

  /// No description provided for @startedLate.
  ///
  /// In en, this message translates to:
  /// **'Started {duration} late'**
  String startedLate(String duration);

  /// No description provided for @startedEarly.
  ///
  /// In en, this message translates to:
  /// **'Started {duration} early'**
  String startedEarly(String duration);

  /// No description provided for @byActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'By activity'**
  String get byActivityTitle;

  /// No description provided for @activityRowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done · {tracked} tracked'**
  String activityRowSubtitle(int done, int total, String tracked);

  /// No description provided for @analyticsEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing was planned for this day.'**
  String get analyticsEmptyDay;

  /// No description provided for @analyticsEmptyWeek.
  ///
  /// In en, this message translates to:
  /// **'Nothing was planned for this week.'**
  String get analyticsEmptyWeek;

  /// No description provided for @analyticsEmptyMonth.
  ///
  /// In en, this message translates to:
  /// **'Nothing was planned for this month.'**
  String get analyticsEmptyMonth;

  /// No description provided for @historyLimited.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Your plan includes today\'s history only.} other{Your plan includes the last {days} days of history.}}'**
  String historyLimited(int days);

  /// No description provided for @seePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get seePlans;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityNotFound.
  ///
  /// In en, this message translates to:
  /// **'This activity has no history yet, or it was deleted.'**
  String get activityNotFound;

  /// No description provided for @activitySince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String activitySince(String date);

  /// No description provided for @streakCurrent.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakCurrent;

  /// No description provided for @streakValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None yet} =1{1 in a row} other{{count} in a row}}'**
  String streakValue(int count);

  /// No description provided for @streakBest.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Best: none yet} other{Best: {count} in a row}}'**
  String streakBest(int count);

  /// No description provided for @historyChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent occurrences'**
  String get historyChartTitle;

  /// No description provided for @historyChartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The last occurrence} other{The last {count} occurrences}}'**
  String historyChartSubtitle(int count);

  /// No description provided for @suggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested duration'**
  String get suggestionTitle;

  /// No description provided for @suggestionBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{Your last {count} timed sessions took about {suggested}. It is planned for {current}.}}'**
  String suggestionBody(int count, String suggested, String current);

  /// No description provided for @suggestionApply.
  ///
  /// In en, this message translates to:
  /// **'Plan {duration} from now on'**
  String suggestionApply(String duration);

  /// No description provided for @suggestionApplied.
  ///
  /// In en, this message translates to:
  /// **'Expected duration updated'**
  String get suggestionApplied;

  /// No description provided for @suggestionLocked.
  ///
  /// In en, this message translates to:
  /// **'Duration suggestions are included with advanced analytics.'**
  String get suggestionLocked;

  /// No description provided for @activityInsights.
  ///
  /// In en, this message translates to:
  /// **'Activity insights'**
  String get activityInsights;

  /// No description provided for @activityInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Streaks and how long it really takes'**
  String get activityInsightsSubtitle;

  /// No description provided for @addByVoice.
  ///
  /// In en, this message translates to:
  /// **'Add by voice'**
  String get addByVoice;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Add by voice'**
  String get voiceTitle;

  /// No description provided for @voiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// No description provided for @voiceExample.
  ///
  /// In en, this message translates to:
  /// **'Try: “Run tomorrow at 7 for 30 minutes”, “Pay rent on the 1st of every month”'**
  String get voiceExample;

  /// No description provided for @voiceExampleShort.
  ///
  /// In en, this message translates to:
  /// **'Call mom tomorrow at 6 pm'**
  String get voiceExampleShort;

  /// No description provided for @voiceStop.
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get voiceStop;

  /// No description provided for @voiceHeard.
  ///
  /// In en, this message translates to:
  /// **'“{text}”'**
  String voiceHeard(String text);

  /// No description provided for @voiceUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what I understood'**
  String get voiceUnderstood;

  /// No description provided for @voiceOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Only the title was understood. You can add the rest in the next step.'**
  String get voiceOnlyTitle;

  /// No description provided for @voiceContinue.
  ///
  /// In en, this message translates to:
  /// **'Review and save'**
  String get voiceContinue;

  /// No description provided for @voiceTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get voiceTryAgain;

  /// No description provided for @voiceUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn\'t available on this device. You can type the task instead.'**
  String get voiceUnsupported;

  /// No description provided for @voiceNothingHeard.
  ///
  /// In en, this message translates to:
  /// **'Nothing was heard. Try again a little closer to the microphone.'**
  String get voiceNothingHeard;

  /// No description provided for @voiceNetwork.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition needs an internet connection on this device.'**
  String get voiceNetwork;

  /// No description provided for @voiceBusy.
  ///
  /// In en, this message translates to:
  /// **'The microphone is being used by another app.'**
  String get voiceBusy;

  /// No description provided for @voiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while listening. Try again.'**
  String get voiceFailed;

  /// No description provided for @voiceTypeInstead.
  ///
  /// In en, this message translates to:
  /// **'Or type it'**
  String get voiceTypeInstead;

  /// No description provided for @voiceUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Understand'**
  String get voiceUnderstand;

  /// No description provided for @voiceDraftBanner.
  ///
  /// In en, this message translates to:
  /// **'From what you said: “{text}”. Check the details, then save.'**
  String voiceDraftBanner(String text);

  /// No description provided for @prefillWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get prefillWhen;

  /// No description provided for @prefillRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get prefillRepeats;

  /// No description provided for @prefillCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get prefillCategory;

  /// No description provided for @prefillNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get prefillNotSet;

  /// No description provided for @subscriptionHeadline.
  ///
  /// In en, this message translates to:
  /// **'Plan more. Learn more.'**
  String get subscriptionHeadline;

  /// No description provided for @subscriptionSubheadline.
  ///
  /// In en, this message translates to:
  /// **'Pro removes the limits and adds deeper insights into how your time really goes.'**
  String get subscriptionSubheadline;

  /// No description provided for @planFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planFree;

  /// No description provided for @planPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get planPro;

  /// No description provided for @planUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get planUnlimited;

  /// No description provided for @planActiveTasks.
  ///
  /// In en, this message translates to:
  /// **'Active tasks'**
  String get planActiveTasks;

  /// No description provided for @planRepeatingTasks.
  ///
  /// In en, this message translates to:
  /// **'Repeating tasks'**
  String get planRepeatingTasks;

  /// No description provided for @planEveryFewDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat every few days or weeks'**
  String get planEveryFewDays;

  /// No description provided for @planAnalyticsHistory.
  ///
  /// In en, this message translates to:
  /// **'Analytics history'**
  String get planAnalyticsHistory;

  /// No description provided for @planAllHistory.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get planAllHistory;

  /// No description provided for @planDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String planDays(int count);

  /// No description provided for @planDurationSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Duration suggestions'**
  String get planDurationSuggestions;

  /// No description provided for @planIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get planIncluded;

  /// No description provided for @planNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Not included'**
  String get planNotIncluded;

  /// No description provided for @offerAnnual.
  ///
  /// In en, this message translates to:
  /// **'{price} per year'**
  String offerAnnual(String price);

  /// No description provided for @offerMonthly.
  ///
  /// In en, this message translates to:
  /// **'{price} per month'**
  String offerMonthly(String price);

  /// No description provided for @offerPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} a month'**
  String offerPerMonth(String price);

  /// No description provided for @offerTrial.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1-day free trial} other{{days}-day free trial}}'**
  String offerTrial(int days);

  /// No description provided for @subscriptionStartTrial.
  ///
  /// In en, this message translates to:
  /// **'Start free trial'**
  String get subscriptionStartTrial;

  /// No description provided for @subscriptionSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscriptionSubscribe;

  /// No description provided for @subscriptionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get subscriptionRestore;

  /// No description provided for @subscriptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases aren\'t available in this version of the app.'**
  String get subscriptionUnavailable;

  /// No description provided for @subscriptionLegal.
  ///
  /// In en, this message translates to:
  /// **'Payment is charged to your App Store or Google Play account. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period; you can manage or cancel it in your store account settings. A free trial converts to a paid subscription when it ends unless cancelled.'**
  String get subscriptionLegal;

  /// No description provided for @linkTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get linkTerms;

  /// No description provided for @linkPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get linkPrivacy;

  /// No description provided for @subscriptionWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pro!'**
  String get subscriptionWelcome;

  /// No description provided for @subscriptionNothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore for this store account.'**
  String get subscriptionNothingToRestore;

  /// No description provided for @subscriptionYouArePro.
  ///
  /// In en, this message translates to:
  /// **'You\'re on Pro'**
  String get subscriptionYouArePro;

  /// No description provided for @subscriptionConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming your purchase with our server…'**
  String get subscriptionConfirming;

  /// No description provided for @subscriptionManage.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get subscriptionManage;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active.'**
  String get statusActive;

  /// No description provided for @statusRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}.'**
  String statusRenews(String date);

  /// No description provided for @statusEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends on {date}. It won\'t renew.'**
  String statusEnds(String date);

  /// No description provided for @statusTrialEnds.
  ///
  /// In en, this message translates to:
  /// **'Free trial until {date}.'**
  String statusTrialEnds(String date);

  /// No description provided for @statusBillingIssue.
  ///
  /// In en, this message translates to:
  /// **'There\'s a problem with your payment.'**
  String get statusBillingIssue;

  /// No description provided for @statusBillingIssueHelp.
  ///
  /// In en, this message translates to:
  /// **'Update your payment method in your store account to keep Pro.'**
  String get statusBillingIssueHelp;

  /// No description provided for @purchasePending.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is waiting for approval. Pro unlocks as soon as it goes through.'**
  String get purchasePending;

  /// No description provided for @purchaseNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Purchases are turned off on this device.'**
  String get purchaseNotAllowed;

  /// No description provided for @entitlementAdvancedRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Repeating every few days or weeks is part of Pro.'**
  String get entitlementAdvancedRecurrence;

  /// No description provided for @entitlementAdvancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'This is part of Pro.'**
  String get entitlementAdvancedAnalytics;

  /// No description provided for @limitActiveSeries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your plan includes 1 active task. End one or upgrade to add more.} other{Your plan includes {count} active tasks. End one or upgrade to add more.}}'**
  String limitActiveSeries(int count);

  /// No description provided for @limitRecurringSeries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your plan includes 1 repeating task.} other{Your plan includes {count} repeating tasks.}}'**
  String limitRecurringSeries(int count);

  /// No description provided for @limitVoicePerMonth.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You\'ve used your 1 voice entry this month.} other{You\'ve used your {count} voice entries this month.}}'**
  String limitVoicePerMonth(int count);

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTitle;

  /// No description provided for @syncStatusUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All changes synced'**
  String get syncStatusUpToDate;

  /// No description provided for @syncStatusPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change waiting to sync} other{{count} changes waiting to sync}}'**
  String syncStatusPending(int count);

  /// No description provided for @syncStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline. Changes are saved on this device.'**
  String get syncStatusOffline;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Last sync didn\'t finish'**
  String get syncStatusFailed;

  /// No description provided for @syncStatusNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get syncStatusNotYet;

  /// time is a localized time of day, e.g. 14:05
  ///
  /// In en, this message translates to:
  /// **'Last synced {time}'**
  String syncLastSynced(String time);

  /// No description provided for @syncNowAction.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNowAction;

  /// No description provided for @syncDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Everything is up to date'**
  String get syncDoneMessage;

  /// No description provided for @syncOfflineExplanation.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Everything you do is saved on this device and syncs when you\'re back online.'**
  String get syncOfflineExplanation;

  /// No description provided for @syncExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your tasks are saved on this device first and synced with your account in the background.'**
  String get syncExplanation;

  /// No description provided for @syncIssuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes that couldn\'t sync'**
  String get syncIssuesTitle;

  /// No description provided for @syncIssueDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get syncIssueDismiss;

  /// No description provided for @syncIssueDismissAll.
  ///
  /// In en, this message translates to:
  /// **'Dismiss all'**
  String get syncIssueDismissAll;

  /// No description provided for @syncIssueUnnamedTask.
  ///
  /// In en, this message translates to:
  /// **'A task'**
  String get syncIssueUnnamedTask;

  /// No description provided for @syncIssueUnnamedCategory.
  ///
  /// In en, this message translates to:
  /// **'A category'**
  String get syncIssueUnnamedCategory;

  /// No description provided for @syncIssueUnnamedOther.
  ///
  /// In en, this message translates to:
  /// **'A change'**
  String get syncIssueUnnamedOther;

  /// No description provided for @syncIssueDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted on another device. Your change was discarded.'**
  String get syncIssueDeleted;

  /// No description provided for @syncIssueConflict.
  ///
  /// In en, this message translates to:
  /// **'Changed on another device. That version was kept.'**
  String get syncIssueConflict;

  /// No description provided for @syncIssuePlan.
  ///
  /// In en, this message translates to:
  /// **'Not included in your current plan. Your change was discarded.'**
  String get syncIssuePlan;

  /// No description provided for @syncIssueInvalid.
  ///
  /// In en, this message translates to:
  /// **'The server couldn\'t accept this change.'**
  String get syncIssueInvalid;

  /// No description provided for @syncIssueFailed.
  ///
  /// In en, this message translates to:
  /// **'This change kept failing and was discarded.'**
  String get syncIssueFailed;

  /// No description provided for @syncIssueOther.
  ///
  /// In en, this message translates to:
  /// **'The server refused this change.'**
  String get syncIssueOther;

  /// Server error code, shown for support
  ///
  /// In en, this message translates to:
  /// **'Code {code}'**
  String syncIssueCode(String code);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
