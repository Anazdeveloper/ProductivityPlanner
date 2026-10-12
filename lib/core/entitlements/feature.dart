/// Boolean capabilities gated by plan. Keys match the server's `plans.features`
/// values (approved design, section 11), so the app never invents its own names.
enum Feature {
  advancedRecurrence('feature.advanced_recurrence'),
  insights('feature.insights'),
  calendar('feature.calendar'),
  advancedAnalytics('feature.advanced_analytics'),
  ai('feature.ai');

  const Feature(this.key);

  final String key;
}

/// Numeric limits gated by plan. Keys match the server's `plans.limits` JSON.
enum LimitKey {
  activeSeries('limit.active_series'),
  recurringSeries('limit.recurring_series'),
  remindersPerTask('limit.reminders_per_task'),
  voicePerMonth('limit.voice_per_month'),
  analyticsHistoryDays('limit.analytics_history_days');

  const LimitKey(this.key);

  final String key;
}
