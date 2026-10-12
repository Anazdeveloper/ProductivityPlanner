import 'package:productivity_planner/core/result/result.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/tasks/domain/validation/task_rules.dart';
import 'package:productivity_planner/features/voice/domain/entities/parsed_task.dart';
import 'package:productivity_planner/features/voice/domain/services/task_text_parser.dart';

/// On-device, rule-based extraction for English sentences such as
/// "Run tomorrow at 7 for 30 minutes every weekday" or "Pay rent on the
/// 1st of every month".
///
/// Each understood phrase is removed from the sentence; what is left
/// becomes the title. Anything it does not understand stays in the title,
/// so nothing said is lost, and the person checks everything in the
/// editor before saving. Rules (documented in docs/VOICE_SETUP.md):
///
/// - A bare hour without am/pm: 1–6 → afternoon (13–18 h), 7–11 → morning.
/// - A weekday ("Friday", "on Friday", "this Friday") is the next such day,
///   today included; "next Friday" is the Friday of next week.
/// - A time already past today, with no date or repetition said, moves to
///   tomorrow.
/// - A date without a year is the next such date.
final class EnglishTaskTextParser implements TaskTextParser {
  const EnglishTaskTextParser();

  @override
  Future<Result<ParsedTask>> parse(String text, ParseContext context) async =>
      Ok(parseText(text, context));

  /// Synchronous form (the parser does no I/O).
  ParsedTask parseText(String text, ParseContext context) =>
      _Parse(text, context).run();
}

// Patterns are written with `<TOKEN>` placeholders (expanded by [_expand])
// and `\s` instead of literal spaces. Text is matched in lower case.

const _numberWords = <String, int>{
  'a': 1,
  'an': 1,
  'one': 1,
  'two': 2,
  'three': 3,
  'four': 4,
  'five': 5,
  'six': 6,
  'seven': 7,
  'eight': 8,
  'nine': 9,
  'ten': 10,
  'eleven': 11,
  'twelve': 12,
  'fifteen': 15,
  'twenty': 20,
  'thirty': 30,
  'forty five': 45,
  'forty-five': 45,
  'forty': 40,
  'fifty': 50,
  'sixty': 60,
  'ninety': 90,
};

const _tokens = <String, String>{
  // A number: digits (decimals allowed) or a number word.
  '<N>':
      r'(\d+(?:\.\d+)?|forty[-\s]five|an?|one|two|three|four|five|six|seven|'
      'eight|nine|ten|eleven|twelve|fifteen|twenty|thirty|forty|fifty|'
      'sixty|ninety)',
  // An hour of the day: digits or a word.
  '<H>':
      r'(\d{1,2}|one|two|three|four|five|six|seven|eight|nine|ten|eleven|'
      'twelve)',
  '<HOURS>': '(?:hours?|hrs?|h)',
  '<MINUTES>': '(?:minutes?|mins?|m)',
  '<MER>': r'(a\.?\s?m\.?|p\.?\s?m\.?)',
  '<DAY>':
      '(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday|tues|'
      'tue|wed|thurs|thur|thu|fri|sat|sun|mon)',
  '<DAYS>':
      '(?:mondays|tuesdays|wednesdays|thursdays|fridays|saturdays|sundays)',
  '<SEP>': r'\s*(?:,\s*and|,|and|&)\s*',
  // "for", "for about": introduces a duration.
  '<LEAD>': r'\bfor\s+(?:about\s+|around\s+|roughly\s+)?',
  '<MONTH>':
      '(january|february|march|april|may|june|july|august|september|'
      'october|november|december|jan|feb|mar|apr|jun|jul|aug|sept|sep|oct|'
      'nov|dec)',
  '<ORD>': r'(\d{1,2})(?:st|nd|rd|th)?',
};

String _expand(String pattern) {
  var result = pattern;
  for (final MapEntry(:key, :value) in _tokens.entries) {
    result = result.replaceAll(key, value);
  }
  return result;
}

final _dayPattern = RegExp(_expand('<DAY>'));

const _dayNames = <String, int>{
  'monday': 1,
  'mon': 1,
  'tuesday': 2,
  'tues': 2,
  'tue': 2,
  'wednesday': 3,
  'wed': 3,
  'thursday': 4,
  'thurs': 4,
  'thur': 4,
  'thu': 4,
  'friday': 5,
  'fri': 5,
  'saturday': 6,
  'sat': 6,
  'sunday': 7,
  'sun': 7,
};

const _monthNames = <String, int>{
  'january': 1,
  'jan': 1,
  'february': 2,
  'feb': 2,
  'march': 3,
  'mar': 3,
  'april': 4,
  'apr': 4,
  'may': 5,
  'june': 6,
  'jun': 6,
  'july': 7,
  'jul': 7,
  'august': 8,
  'aug': 8,
  'september': 9,
  'sept': 9,
  'sep': 9,
  'october': 10,
  'oct': 10,
  'november': 11,
  'nov': 11,
  'december': 12,
  'dec': 12,
};

/// Words that suggest a default category (by its English name). The
/// first keyword found in the sentence wins; keywords stay in the title.
const _categoryKeywords = <String, String>{
  'run': 'health',
  'running': 'health',
  'jog': 'health',
  'gym': 'health',
  'workout': 'health',
  'exercise': 'health',
  'yoga': 'health',
  'meditate': 'health',
  'meditation': 'health',
  'walk': 'health',
  'swim': 'health',
  'cycling': 'health',
  'stretch': 'health',
  'doctor': 'health',
  'dentist': 'health',
  'medicine': 'health',
  'meeting': 'work',
  'standup': 'work',
  'stand-up': 'work',
  'email': 'work',
  'emails': 'work',
  'report': 'work',
  'presentation': 'work',
  'client': 'work',
  'interview': 'work',
  'study': 'study',
  'homework': 'study',
  'exam': 'study',
  'revise': 'study',
  'revision': 'study',
  'lecture': 'study',
  'course': 'study',
  'learn': 'study',
  'clean': 'home',
  'laundry': 'home',
  'dishes': 'home',
  'cook': 'home',
  'groceries': 'home',
  'vacuum': 'home',
  'plants': 'home',
  'trash': 'home',
  'garbage': 'home',
  'rent': 'home',
  'bills': 'home',
  'birthday': 'personal',
  'mom': 'personal',
  'dad': 'personal',
  'family': 'personal',
  'friend': 'personal',
};

enum _Period { morning, afternoon, evening, night }

const _periodWords = <String, _Period>{
  'morning': _Period.morning,
  'afternoon': _Period.afternoon,
  'evening': _Period.evening,
  'night': _Period.night,
  'tonight': _Period.night,
};

/// One parse: consumes understood phrases from the sentence.
final class _Parse {
  _Parse(this.text, this.context)
    : _lower = text.toLowerCase(),
      _used = List<bool>.filled(text.toLowerCase().length, false);

  final String text;
  final ParseContext context;
  final String _lower;
  final List<bool> _used;

  /// The title is built from the original text, unless lower-casing
  /// changed its length (a few scripts): then from the lower-case text.
  String get _source => _lower.length == text.length ? text : _lower;

  LocalDate? _date;
  bool _dateSaid = false;
  LocalTime? _time;
  _Period? _period;
  bool _anyTime = false;
  Duration? _duration;
  RecurrenceRule? _rule;
  int? _monthDay;
  Category? _category;

  ParsedTask run() {
    _filler();
    _explicitCategory();
    _recurrence();
    // Before durations, so "in 20 minutes" is a time, not a length.
    _relativeTime();
    _durations();
    _dates();
    _times();
    _anyTimeWords();
    _resolve();
    final title = _title();
    return ParsedTask(
      text: text.trim(),
      today: context.today,
      title: title,
      date: _date,
      startTime: _time,
      anyTime: _anyTime && _time == null,
      expectedDuration: _duration,
      recurrence: _rule,
      category: _category ?? _inferCategory(title),
    );
  }

  // Matching helpers

  /// The first match of [pattern] (tokens expanded) that does not overlap
  /// a consumed part; it is consumed.
  RegExpMatch? _take(String pattern) {
    for (final match in RegExp(_expand(pattern)).allMatches(_lower)) {
      if (match.end == match.start) continue;
      if (_isFree(match.start, match.end)) {
        _consume(match.start, match.end);
        return match;
      }
    }
    return null;
  }

  bool _isFree(int start, int end) {
    for (var i = start; i < end; i++) {
      if (_used[i]) return false;
    }
    return true;
  }

  void _consume(int start, int end) {
    for (var i = start; i < end; i++) {
      _used[i] = true;
    }
  }

  /// A period word right after a consumed date ("tomorrow morning").
  void _takeFollowingPeriod(int from) {
    final match = RegExp(
      r'^\s+(morning|afternoon|evening|night)\b',
    ).firstMatch(_lower.substring(from));
    if (match == null) return;
    final start = from + match.start;
    final end = from + match.end;
    if (!_isFree(start, end)) return;
    _consume(start, end);
    _period ??= _periodWords[match.group(1)];
  }

  static int? _number(String? word) {
    if (word == null) return null;
    return int.tryParse(word) ??
        _numberWords[word.replaceAll(RegExp(r'\s+'), ' ')];
  }

  static double? _decimal(String? word) {
    if (word == null) return null;
    return double.tryParse(word) ?? _number(word)?.toDouble();
  }

  // Phrases

  void _filler() {
    _take(
      r'^\s*(?:please\s+)?(?:(?:can|could)\s+you\s+)?'
      r'(?:remind\s+me\s+(?:to|about)|i\s+(?:need|have|want)\s+to|'
      r"i've\s+got\s+to|i\s+gotta|"
      r'add\s+(?:a\s+)?(?:new\s+)?(?:task|reminder)(?:\s+to)?|'
      r'create\s+(?:a\s+)?(?:new\s+)?(?:task|reminder)(?:\s+to)?|'
      r'new\s+task|set\s+(?:a\s+)?reminder\s+(?:to|for)|schedule)\b',
    );
  }

  void _explicitCategory() {
    for (final category in context.categories) {
      final name = RegExp.escape(category.name.toLowerCase().trim());
      if (name.isEmpty) continue;
      String named(String pattern) => pattern.replaceAll('<NAME>', name);
      final match =
          _take(named(r'#<NAME>\b')) ??
          _take(
            named(
              r'\b(?:for|in|under|to)\s+(?:the\s+|my\s+)?<NAME>'
              r'\s+(?:category|list|tasks?)\b',
            ),
          ) ??
          _take(named(r'\b(?:in|under)\s+(?:the\s+|my\s+)?<NAME>\b')) ??
          _take(named(r'\bfor\s+<NAME>\b')) ??
          _take(named(r'\b<NAME>\s+(?:category|list)\b'));
      if (match != null) {
        _category = category;
        return;
      }
    }
  }

  void _recurrence() {
    if (_take(
          r'\b(?:every|each)\s+(?:week\s?day|work\s?day)s?\b|'
          r'\bon\s+weekdays\b|\bweekdays\b',
        ) !=
        null) {
      _rule = const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [1, 2, 3, 4, 5],
      );
    } else if (_take(
          r'\b(?:every|each)\s+weekends?\b|\bon\s+weekends\b|\bweekends\b',
        ) !=
        null) {
      _rule = const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        weekdays: [6, 7],
      );
    } else if (_take(r'\bevery\s+(?:other|second)\s+(<DAY>)s?\b')
        case final m?) {
      _rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        weekdays: _weekdays(m.group(1) ?? ''),
      );
    } else if (_take(r'\b(?:every|each)\s+(<DAY>s?(?:<SEP><DAY>s?)*)\b') ??
            _take(r'\b(?:on\s+)?(<DAYS>(?:<SEP><DAY>s?)*)\b')
        case final m?) {
      _rule = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        weekdays: _weekdays(m.group(1) ?? ''),
      );
    } else if (_take(r'\bevery\s+(?:other|second)\s+day\b') != null) {
      _rule = const RecurrenceRule(
        frequency: RecurrenceFrequency.daily,
        interval: 2,
      );
    } else if (_take(r'\bevery\s+<N>\s+days\b') case final m?) {
      _rule = _every(RecurrenceFrequency.daily, m.group(1));
    } else if (_take(r'\b(?:every|each)\s*day\b|\bdaily\b|\beveryday\b') !=
        null) {
      _rule = const RecurrenceRule(frequency: RecurrenceFrequency.daily);
    } else if (_take(
              r'\b(?:on\s+)?the\s+<ORD>\s+(?:day\s+)?(?:of\s+)?'
              r'(?:every|each)\s+month\b',
            ) ??
            _take(
              r'\b(?:(?:every|each)\s+month|monthly)\s+on\s+the\s+<ORD>\b',
            ) ??
            _take(r'\bevery\s+(\d{1,2})(?:st|nd|rd|th)\b')
        case final m?) {
      // Monthly on a day: "on the 1st of every month", "every month on
      // the 15th", "monthly on the 3rd", "every 20th".
      final day = int.tryParse(m.group(1) ?? '');
      if (day != null && day >= 1 && day <= 31) {
        _monthDay = day;
        _rule = const RecurrenceRule(frequency: RecurrenceFrequency.monthly);
      }
    } else if (_take(r'\bevery\s+(?:other|second)\s+week\b') != null) {
      _rule = const RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
      );
    } else if (_take(r'\bevery\s+<N>\s+weeks\b') case final m?) {
      _rule = _every(RecurrenceFrequency.weekly, m.group(1));
    } else if (_take(r'\b(?:every|each)\s+week\b|\bweekly\b') != null) {
      _rule = const RecurrenceRule(frequency: RecurrenceFrequency.weekly);
    } else if (_take(r'\bevery\s+(?:other|second)\s+month\b') != null) {
      _rule = const RecurrenceRule(
        frequency: RecurrenceFrequency.monthly,
        interval: 2,
      );
    } else if (_take(r'\bevery\s+<N>\s+months\b') case final m?) {
      _rule = _every(RecurrenceFrequency.monthly, m.group(1));
    } else if (_take(r'\b(?:every|each)\s+month\b|\bmonthly\b') != null) {
      _rule = const RecurrenceRule(frequency: RecurrenceFrequency.monthly);
    }
  }

  /// "Every N …", with N kept within what the task rules allow.
  static RecurrenceRule _every(RecurrenceFrequency frequency, String? word) {
    final max = TaskRules.maxInterval(frequency);
    final value = _number(word) ?? 1;
    return RecurrenceRule(
      frequency: frequency,
      interval: value < 1 ? 1 : (value > max ? max : value),
    );
  }

  static List<int> _weekdays(String list) {
    final days = <int>{
      for (final match in _dayPattern.allMatches(list))
        if (_dayNames[match.group(0)] case final day?) day,
    };
    return days.toList()..sort();
  }

  void _durations() {
    if (_take(r'<LEAD>half\s+an\s+hour\b') != null) {
      _setDuration(const Duration(minutes: 30));
    } else if (_take(r'<LEAD>(?:an|one)\s+hour\s+and\s+a\s+half\b') !=
        null) {
      _setDuration(const Duration(minutes: 90));
    } else if (_take(
          r'<LEAD><N>(\s+and\s+a\s+half)?\s*<HOURS>\b'
          r'(?:\s*(?:and\s+)?<N>\s*<MINUTES>\b)?',
        )
        case final m?) {
      final hours = _decimal(m.group(1)) ?? 0;
      final half = m.group(2) != null ? 0.5 : 0.0;
      final minutes = _number(m.group(3)) ?? 0;
      _setDuration(
        Duration(minutes: ((hours + half) * 60).round() + minutes),
      );
    } else if (_take(r'<LEAD><N>\s*<MINUTES>\b') case final m?) {
      _setDuration(Duration(minutes: _number(m.group(1)) ?? 0));
    } else if (_take(r'(?<!\bevery\s)\b(\d+)[-\s](?:minute|min)s?\b')
        case final m?) {
      // "a 30-minute walk" (but not "every 30 minutes")
      _setDuration(Duration(minutes: _number(m.group(1)) ?? 0));
    } else if (_take(r'(?<!\bevery\s)\b(\d+)[-\s]hours?\b') case final m?) {
      // "a 2 hour session"
      _setDuration(Duration(hours: _number(m.group(1)) ?? 0));
    }
  }

  void _setDuration(Duration value) {
    if (value >= TaskRules.minDuration && value <= TaskRules.maxDuration) {
      _duration = value;
    }
  }

  /// "in 20 minutes", "in an hour", "in half an hour".
  void _relativeTime() {
    int? minutes;
    if (_take(r'\bin\s+half\s+an\s+hour\b') != null) {
      minutes = 30;
    } else if (_take(r'\bin\s+<N>\s*<HOURS>\b') case final m?) {
      minutes = ((_decimal(m.group(1)) ?? 0) * 60).round();
    } else if (_take(r'\bin\s+<N>\s*<MINUTES>\b') case final m?) {
      minutes = _number(m.group(1));
    }
    if (minutes == null || minutes <= 0) return;
    final total = context.now.minutesOfDay + minutes;
    _date = context.today.addDays(total ~/ (24 * 60));
    _dateSaid = true;
    final ofDay = total % (24 * 60);
    _time = LocalTime(ofDay ~/ 60, ofDay % 60);
  }

  void _dates() {
    final today = context.today;
    if (_take(r'\b(?:the\s+)?day\s+after\s+tomorrow\b') case final m?) {
      _setDate(today.addDays(2), m);
    } else if (_take(r'\b(?:tomorrow|tmrw|tomorow)\b') case final m?) {
      _setDate(today.addDays(1), m);
    } else if (_take(r'\btonight\b') case final m?) {
      _setDate(today, m);
      _period ??= _Period.night;
    } else if (_take(r'\btoday\b') case final m?) {
      _setDate(today, m);
    } else if (_take(r'\bthis\s+(morning|afternoon|evening)\b')
        case final m?) {
      _setDate(today, null);
      _period ??= _periodWords[m.group(1)];
    } else if (_take(r'\bnext\s+week\b') != null) {
      _setDate(today.startOfIsoWeek.addDays(7), null);
    } else if (_take(r'\bin\s+<N>\s+(days?|weeks?)\b') case final m?) {
      final count = _number(m.group(1)) ?? 0;
      final weeks = (m.group(2) ?? '').startsWith('week');
      _setDate(today.addDays(weeks ? count * 7 : count), null);
    } else if (_take(r'\b(?:on\s+)?(?:(this|next|coming)\s+)?(<DAY>)\b')
        case final m?) {
      final day = _dayNames[m.group(2)] ?? today.weekday;
      final date = m.group(1) == 'next'
          ? today.startOfIsoWeek.addDays(7 + day - 1)
          : today.addDays((day - today.weekday) % 7);
      _setDate(date, m);
    } else if (_take(r'\b(?:on\s+)?<MONTH>\s+<ORD>(?:,?\s+(\d{4}))?\b')
        case final m?) {
      _setDate(
        _calendarDate(
          month: _monthNames[m.group(1)],
          day: int.tryParse(m.group(2) ?? ''),
          year: int.tryParse(m.group(3) ?? ''),
        ),
        m,
      );
    } else if (_take(
          r'\b(?:on\s+)?(?:the\s+)?<ORD>\s+(?:of\s+)?<MONTH>'
          r'(?:,?\s+(\d{4}))?\b',
        )
        case final m?) {
      _setDate(
        _calendarDate(
          month: _monthNames[m.group(2)],
          day: int.tryParse(m.group(1) ?? ''),
          year: int.tryParse(m.group(3) ?? ''),
        ),
        m,
      );
    } else if (_take(r'\bon\s+the\s+(\d{1,2})(?:st|nd|rd|th)\b')
        case final m?) {
      final day = int.tryParse(m.group(1) ?? '');
      if (day != null) _setDate(_nextDayOfMonth(day), m);
    }
  }

  void _setDate(LocalDate? date, RegExpMatch? match) {
    if (date == null) return;
    _date = date;
    _dateSaid = true;
    if (match != null) _takeFollowingPeriod(match.end);
  }

  /// The next [month]/[day] from today (or in [year]); null if it does not
  /// exist.
  LocalDate? _calendarDate({int? month, int? day, int? year}) {
    if (month == null || day == null) return null;
    LocalDate? attempt(int y) {
      try {
        return LocalDate(y, month, day);
      } on ArgumentError {
        return null;
      }
    }

    if (year != null) return attempt(year);
    final today = context.today;
    // Up to 8 years ahead finds the next 29 February.
    for (var y = today.year; y <= today.year + 8; y++) {
      final date = attempt(y);
      if (date != null && date >= today) return date;
    }
    return null;
  }

  /// The next date (from today) that has [day] as its day of month.
  LocalDate? _nextDayOfMonth(int day) {
    if (day < 1 || day > 31) return null;
    var year = context.today.year;
    var month = context.today.month;
    for (var i = 0; i < 13; i++) {
      final days = DateTime.utc(year, month + 1, 0).day;
      if (day <= days) {
        final date = LocalDate(year, month, day);
        if (date >= context.today) return date;
      }
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
    return null;
  }

  void _times() {
    if (_time != null) return;
    if (_take(r'\b(?:at\s+|around\s+|by\s+)?(?:noon|midday)\b') != null) {
      _time = LocalTime(12, 0);
    } else if (_take(
          r'\b(?:at\s+|around\s+|by\s+)?'
          r'(half\s+past|quarter\s+past|quarter\s+to)\s+<H>'
          r'(?:\s*<MER>)?(?![\w:])',
        )
        case final m?) {
      final hour = _number(m.group(2));
      if (hour == null) return;
      final (h, minute) = switch (m.group(1)?.replaceAll(RegExp(r'\s+'), ' ')) {
        'half past' => (hour, 30),
        'quarter past' => (hour, 15),
        // "quarter to one" is 12:45.
        _ => (hour == 1 ? 12 : hour - 1, 45),
      };
      _setClock(h, minute, m.group(3));
    } else if (_take(
          // "at 7", "at 7:30 pm", "around 18:00", "at seven o'clock"
          r'\b(?:at|around|by|from)\s+<H>(?:[:.](\d{2}))?\s*'
          r'(?:o.?clock)?\s*<MER>?(?![\w:])',
        )
        case final m?) {
      final hour = _number(m.group(1));
      if (hour != null) {
        _setClock(hour, int.tryParse(m.group(2) ?? '') ?? 0, m.group(3));
      }
    } else if (
        // "7pm", "7:30 am"
        _take(r'\b(\d{1,2})(?:[:.](\d{2}))?\s*<MER>(?![\w:])') ??
            // "seven o'clock"
            _take(r"\b<H>()\s+o'?clock\b()") ??
            // "19:30"
            _take(r'\b(\d{1,2}):(\d{2})\b()')
        case final m?) {
      final hour = _number(m.group(1));
      if (hour != null) {
        _setClock(hour, int.tryParse(m.group(2) ?? '') ?? 0, m.group(3));
      }
    } else if (_take(r'\bin\s+the\s+(morning|afternoon|evening)\b')
        case final m?) {
      // A period on its own: "in the morning", "at night".
      _period ??= _periodWords[m.group(1)];
    } else if (_take(r'\bat\s+night\b') != null) {
      _period ??= _Period.night;
    }
  }

  /// Sets the time from a spoken hour, minute and optional am/pm, using
  /// the period ("in the evening") or the bare-hour rule.
  void _setClock(int hour, int minute, String? meridiem) {
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return;
    var h = hour;
    final marker = meridiem?.replaceAll(RegExp(r'[\s.]'), '');
    if (marker == 'am') {
      if (h == 12) h = 0;
    } else if (marker == 'pm') {
      if (h < 12) h += 12;
    } else if (h >= 1 && h <= 12) {
      // The period may come later in the sentence ("at 7 in the evening").
      _periodLookahead();
      switch (_period) {
        case _Period.morning:
          if (h == 12) h = 0;
        case _Period.afternoon || _Period.evening || _Period.night:
          if (h < 12) h += 12;
        case null:
          if (h <= 6) h += 12;
      }
    }
    if (h > 23) return;
    _time = LocalTime(h, minute);
  }

  void _periodLookahead() {
    if (_period != null) return;
    final m =
        _take(r'\bin\s+the\s+(morning|afternoon|evening)\b') ??
        _take(r'\b(?:at\s+)?(night|tonight)\b');
    if (m != null) _period = _periodWords[m.group(1)];
  }

  void _anyTimeWords() {
    if (_take(r'\b(?:any\s?time|sometime|some\s+time)\b') != null) {
      _anyTime = true;
    }
  }

  /// Fills defaults that depend on more than one phrase.
  void _resolve() {
    // A period with no clock time: a typical time in it.
    final period = _period;
    if (_time == null && period != null && !_anyTime) {
      _time = switch (period) {
        _Period.morning => LocalTime(9, 0),
        _Period.afternoon => LocalTime(15, 0),
        _Period.evening => LocalTime(19, 0),
        _Period.night => LocalTime(21, 0),
      };
    }
    // Monthly on a given day: start on the next such day.
    final monthDay = _monthDay;
    if (monthDay != null && !_dateSaid) {
      _date = _nextDayOfMonth(monthDay);
    }
    // A time already gone today, with no date or repetition said: tomorrow.
    final time = _time;
    if (!_dateSaid &&
        _rule == null &&
        time != null &&
        time.compareTo(context.now) <= 0) {
      _date = context.today.addDays(1);
    }
  }

  String? _title() {
    final source = _source;
    final buffer = StringBuffer();
    for (var i = 0; i < source.length; i++) {
      buffer.write(_used[i] ? ' ' : source[i]);
    }
    var title = buffer
        .toString()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAllMapped(RegExp(r'\s+([,.;:!?])'), (m) => m.group(1) ?? '')
        .replaceAllMapped(
          RegExp(r'([,;:])(?:\s*[,;:])+'),
          (m) => m.group(1) ?? '',
        )
        .trim();
    final dangling = RegExp(
      r'(?:[\s,;:.!?-]+|\s+(?:at|on|for|and|to|in|by|from|the|every|'
      r'starting|then|around|about))+$',
      caseSensitive: false,
    );
    final leading = RegExp(
      r'^(?:[\s,;:.!?-]+|(?:and|to|then|also)\s+)+',
      caseSensitive: false,
    );
    String previous;
    do {
      previous = title;
      title = title.replaceFirst(dangling, '').replaceFirst(leading, '');
    } while (title != previous);
    if (title.isEmpty) return null;
    return title[0].toUpperCase() + title.substring(1);
  }

  /// A category suggested by keywords in the title, matched to the user's
  /// categories by their default English names.
  Category? _inferCategory(String? title) {
    if (title == null || context.categories.isEmpty) return null;
    final words = RegExp('[a-z][a-z-]*').allMatches(title.toLowerCase());
    for (final word in words) {
      final key = _categoryKeywords[word.group(0)];
      if (key == null) continue;
      for (final category in context.categories) {
        if (category.name.toLowerCase() == key) return category;
      }
    }
    return null;
  }
}
