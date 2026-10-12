import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/core/time/local_time.dart';
import 'package:productivity_planner/features/tasks/domain/entities/category.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_enums.dart';
import 'package:productivity_planner/features/tasks/domain/entities/task_schedule.dart';
import 'package:productivity_planner/features/voice/data/english_task_parser.dart';
import 'package:productivity_planner/features/voice/domain/entities/parsed_task.dart';

const _work = Category(id: 'c-work', name: 'Work', color: CategoryColor.blue);
const _study = Category(id: 'c-study', name: 'Study', color: CategoryColor.purple);
const _health = Category(id: 'c-health', name: 'Health', color: CategoryColor.green);
const _personal = Category(
  id: 'c-personal',
  name: 'Personal',
  color: CategoryColor.orange,
);
const _home = Category(id: 'c-home', name: 'Home', color: CategoryColor.teal);

void main() {
  const parser = EnglishTaskTextParser();
  // Wednesday 7 October 2026, 10:00.
  final context = ParseContext(
    today: LocalDate(2026, 10, 7),
    now: LocalTime(10, 0),
    categories: const [_work, _study, _health, _personal, _home],
  );

  ParsedTask parse(String text) => parser.parseText(text, context);

  group('a full sentence', () {
    test('title, date, time, duration and a suggested category', () {
      final task = parse('Go for a run tomorrow at 7 am for 30 minutes');
      expect(task.title, 'Go for a run');
      expect(task.date, LocalDate(2026, 10, 8));
      expect(task.startTime, LocalTime(7, 0));
      expect(task.expectedDuration, const Duration(minutes: 30));
      expect(task.recurrence, isNull);
      expect(task.category, _health);
      expect(task.today, LocalDate(2026, 10, 7));
    });

    test('weekly on two days, hours, bare hour in the morning', () {
      final task = parse(
        'Study physics for 2 hours every Monday and Wednesday at 8',
      );
      expect(task.title, 'Study physics');
      expect(task.startTime, LocalTime(8, 0));
      expect(task.expectedDuration, const Duration(hours: 2));
      expect(
        task.recurrence,
        const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          weekdays: [1, 3],
        ),
      );
      expect(task.date, isNull, reason: 'starts today in the editor');
      expect(task.category, _study);
    });

    test('an explicit category is removed from the title', () {
      final task = parse('Team meeting next Friday at 10:30 for an hour for work');
      expect(task.title, 'Team meeting');
      expect(task.date, LocalDate(2026, 10, 16), reason: "next week's Friday");
      expect(task.startTime, LocalTime(10, 30));
      expect(task.expectedDuration, const Duration(hours: 1));
      expect(task.category, _work);
    });

    test('filler words are dropped', () {
      final task = parse('Remind me to call mom at 6:30 pm');
      expect(task.title, 'Call mom');
      expect(task.startTime, LocalTime(18, 30));
      expect(task.category, _personal);
    });
  });

  group('repetition', () {
    test('monthly on a day starts on the next such day', () {
      final task = parse('Pay rent on the 1st of every month');
      expect(task.title, 'Pay rent');
      expect(
        task.recurrence,
        const RecurrenceRule(frequency: RecurrenceFrequency.monthly),
      );
      expect(task.date, LocalDate(2026, 11, 1));
    });

    test('every month on the 25th', () {
      final task = parse('Pay credit card bill every month on the 25th');
      expect(task.title, 'Pay credit card bill');
      expect(task.date, LocalDate(2026, 10, 25));
    });

    test('every N days, every other week, weekdays, daily', () {
      expect(
        parse('Water plants every 2 days').recurrence,
        const RecurrenceRule(frequency: RecurrenceFrequency.daily, interval: 2),
      );
      expect(
        parse('Write blog post every other week').recurrence,
        const RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 2),
      );
      expect(
        parse('Yoga on weekdays at 7').recurrence?.weekdays,
        [1, 2, 3, 4, 5],
      );
      final daily = parse('Meditate every day at 6 in the morning for 10 minutes');
      expect(daily.recurrence?.frequency, RecurrenceFrequency.daily);
      expect(daily.startTime, LocalTime(6, 0), reason: '"in the morning"');
      expect(daily.title, 'Meditate');
    });

    test('day lists with & and a #category', () {
      final sync = parse('Team sync every Tuesday & Thursday at 4:30 pm');
      expect(sync.recurrence?.weekdays, [2, 4]);
      expect(sync.startTime, LocalTime(16, 30));
      final standup = parse('Standup at 9:15 every weekday #work');
      expect(standup.title, 'Standup');
      expect(standup.category, _work);
    });
  });

  group('dates', () {
    test('month names, ordinals and day-of-month', () {
      expect(parse('Dentist on October 20 at 3pm').date, LocalDate(2026, 10, 20));
      expect(
        parse('Doctor appointment on 5th November at 11 am').date,
        LocalDate(2026, 11, 5),
      );
      expect(parse('Clean the kitchen on the 15th').date, LocalDate(2026, 10, 15));
      expect(
        parse('Prepare slides for the meeting on December 3rd').title,
        'Prepare slides for the meeting',
      );
    });

    test('weekdays: the next one, today included', () {
      expect(parse('Submit report by Friday').date, LocalDate(2026, 10, 9));
      expect(parse('meeting on monday').date, LocalDate(2026, 10, 12));
      expect(parse('Haircut on Saturday at 10').date, LocalDate(2026, 10, 10));
    });

    test('relative days and weeks', () {
      expect(parse('Visit grandma next week').date, LocalDate(2026, 10, 12));
      expect(parse('Report due in 3 days').date, LocalDate(2026, 10, 10));
    });

    test('a date that does not exist is ignored', () {
      final task = parse('Anniversary dinner on Feb 30');
      expect(task.date, isNull);
      expect(task.title, 'Anniversary dinner');
    });
  });

  group('times', () {
    test('a bare hour 1–6 is in the afternoon', () {
      expect(parse('Pick up kids at 3').startTime, LocalTime(15, 0));
      expect(parse('lunch with Sam at 1 for 90 minutes').startTime, LocalTime(13, 0));
    });

    test('periods choose am or pm and give a default time', () {
      expect(parse('Call at 7 in the evening').startTime, LocalTime(19, 0));
      final gym = parse('Gym tomorrow evening');
      expect(gym.date, LocalDate(2026, 10, 8));
      expect(gym.startTime, LocalTime(19, 0));
      final read = parse('Read for 45 min tonight');
      expect(read.date, LocalDate(2026, 10, 7));
      expect(read.startTime, LocalTime(21, 0));
      expect(read.expectedDuration, const Duration(minutes: 45));
    });

    test('half past, noon and am/pm without "at"', () {
      final call = parse('Call dad at half past seven tonight');
      expect(call.startTime, LocalTime(19, 30));
      expect(parse('Take a 30-minute walk at noon').startTime, LocalTime(12, 0));
      expect(parse('Workout 5 pm').startTime, LocalTime(17, 0));
    });

    test('a time already gone today moves to tomorrow', () {
      final task = parse('Email Priya at 9');
      expect(task.startTime, LocalTime(9, 0));
      expect(task.date, LocalDate(2026, 10, 8));
    });

    test('"in 20 minutes" is a time, not a length', () {
      final task = parse('Call the bank in 20 minutes');
      expect(task.title, 'Call the bank');
      expect(task.date, LocalDate(2026, 10, 7));
      expect(task.startTime, LocalTime(10, 20));
      expect(task.expectedDuration, isNull);
    });

    test('"sometime" means any time that day', () {
      final task = parse('Buy groceries sometime tomorrow');
      expect(task.anyTime, isTrue);
      expect(task.startTime, isNull);
      expect(task.date, LocalDate(2026, 10, 8));
      expect(task.category, _home);
    });
  });

  test('edge cases', () {
    expect(parse('Call at quarter to one').startTime, LocalTime(12, 45));
    expect(parse('Party on Feb 29').date, LocalDate(2028, 2, 29));
    expect(
      parse('Review every 60 weeks').recurrence?.interval,
      52,
      reason: 'the task rules allow at most every 52 weeks',
    );
    expect(
      parse('Practice for forty five minutes').expectedDuration,
      const Duration(minutes: 45),
    );
  });

  group('durations', () {
    test('words, halves and hyphenated forms', () {
      expect(
        parse('Practice guitar for one and a half hours').expectedDuration,
        const Duration(minutes: 90),
      );
      final walk = parse('Take a 30-minute walk at noon');
      expect(walk.expectedDuration, const Duration(minutes: 30));
      expect(walk.title, 'Take a walk');
    });
  });

  group('what is not understood stays in the title', () {
    test('numbers that are not times or lengths', () {
      final task = parse('Read 3 chapters');
      expect(task.title, 'Read 3 chapters');
      expect(task.hasDetails, isFalse);
    });

    test('repetition more often than daily is not supported', () {
      final task = parse('Take medicine every 8 hours');
      expect(task.title, 'Take medicine every 8 hours');
      expect(task.expectedDuration, isNull);
      expect(task.recurrence, isNull);
      expect(parse('Drink water every 30 minutes').expectedDuration, isNull);
    });

    test('a capital letter after a space is kept', () {
      expect(parse('Plan A').title, 'Plan A');
    });

    test('an empty sentence gives no title', () {
      final task = parse('   ');
      expect(task.title, isNull);
      expect(task.hasDetails, isFalse);
    });
  });

  test('the prefill carries the draft and the sentence', () {
    final prefill = parse('Run tomorrow at 7 for 30 minutes').toPrefill();
    expect(prefill.title, 'Run');
    expect(prefill.date, LocalDate(2026, 10, 8));
    expect(prefill.time, LocalTime(7, 0));
    expect(prefill.duration, const Duration(minutes: 30));
    expect(prefill.categoryId, 'c-health');
    expect(prefill.originText, 'Run tomorrow at 7 for 30 minutes');
  });
}
