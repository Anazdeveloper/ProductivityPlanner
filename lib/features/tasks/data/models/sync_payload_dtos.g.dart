// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_payload_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurrenceDto _$RecurrenceDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RecurrenceDto', json, ($checkedConvert) {
      final val = RecurrenceDto(
        frequency: $checkedConvert('frequency', (v) => v as String),
        interval: $checkedConvert('interval', (v) => (v as num).toInt()),
        weekdays: $checkedConvert(
          'weekdays',
          (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
        ),
        monthDay: $checkedConvert('month_day', (v) => (v as num?)?.toInt()),
        until: $checkedConvert('until', (v) => v as String?),
        count: $checkedConvert('count', (v) => (v as num?)?.toInt()),
      );
      return val;
    }, fieldKeyMap: const {'monthDay': 'month_day'});

Map<String, dynamic> _$RecurrenceDtoToJson(RecurrenceDto instance) =>
    <String, dynamic>{
      'frequency': instance.frequency,
      'interval': instance.interval,
      'weekdays': instance.weekdays,
      'month_day': ?instance.monthDay,
      'until': ?instance.until,
      'count': ?instance.count,
    };

SeriesDto _$SeriesDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SeriesDto',
  json,
  ($checkedConvert) {
    final val = SeriesDto(
      id: $checkedConvert('id', (v) => v as String),
      lineageId: $checkedConvert('lineage_id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      priority: $checkedConvert('priority', (v) => v as String),
      plannedDuration: $checkedConvert(
        'planned_duration',
        (v) => (v as num).toInt(),
      ),
      startDate: $checkedConvert('start_date', (v) => v as String),
      timeZone: $checkedConvert('time_zone', (v) => v as String),
      recurrence: $checkedConvert(
        'recurrence',
        (v) => RecurrenceDto.fromJson(v as Map<String, dynamic>),
      ),
      reminderOffsets: $checkedConvert(
        'reminder_offsets',
        (v) => (v as List<dynamic>).map((e) => (e as num).toInt()).toList(),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
      startTime: $checkedConvert('start_time', (v) => v as String?),
      endedOn: $checkedConvert('ended_on', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'lineageId': 'lineage_id',
    'plannedDuration': 'planned_duration',
    'startDate': 'start_date',
    'timeZone': 'time_zone',
    'reminderOffsets': 'reminder_offsets',
    'categoryId': 'category_id',
    'startTime': 'start_time',
    'endedOn': 'ended_on',
  },
);

Map<String, dynamic> _$SeriesDtoToJson(SeriesDto instance) => <String, dynamic>{
  'id': instance.id,
  'lineage_id': instance.lineageId,
  'title': instance.title,
  'notes': ?instance.notes,
  'category_id': ?instance.categoryId,
  'priority': instance.priority,
  'planned_duration': instance.plannedDuration,
  'start_date': instance.startDate,
  'start_time': ?instance.startTime,
  'time_zone': instance.timeZone,
  'recurrence': instance.recurrence.toJson(),
  'reminder_offsets': instance.reminderOffsets,
  'ended_on': ?instance.endedOn,
};

SeriesSplitDto _$SeriesSplitDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'SeriesSplitDto',
      json,
      ($checkedConvert) {
        final val = SeriesSplitDto(
          sourceSeriesId: $checkedConvert(
            'source_series_id',
            (v) => v as String,
          ),
          splitDate: $checkedConvert('split_date', (v) => v as String),
          newSeries: $checkedConvert(
            'new_series',
            (v) => SeriesDto.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'sourceSeriesId': 'source_series_id',
        'splitDate': 'split_date',
        'newSeries': 'new_series',
      },
    );

Map<String, dynamic> _$SeriesSplitDtoToJson(SeriesSplitDto instance) =>
    <String, dynamic>{
      'source_series_id': instance.sourceSeriesId,
      'split_date': instance.splitDate,
      'new_series': instance.newSeries.toJson(),
    };

OccurrenceActionDto _$OccurrenceActionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'OccurrenceActionDto',
      json,
      ($checkedConvert) {
        final val = OccurrenceActionDto(
          seriesId: $checkedConvert('series_id', (v) => v as String),
          originalDate: $checkedConvert('original_date', (v) => v as String),
          sessionId: $checkedConvert('session_id', (v) => v as String?),
          actualDuration: $checkedConvert(
            'actual_duration',
            (v) => (v as num?)?.toInt(),
          ),
          reason: $checkedConvert('reason', (v) => v as String?),
          toDate: $checkedConvert('to_date', (v) => v as String?),
          toStart: $checkedConvert('to_start', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'seriesId': 'series_id',
        'originalDate': 'original_date',
        'sessionId': 'session_id',
        'actualDuration': 'actual_duration',
        'toDate': 'to_date',
        'toStart': 'to_start',
      },
    );

Map<String, dynamic> _$OccurrenceActionDtoToJson(
  OccurrenceActionDto instance,
) => <String, dynamic>{
  'series_id': instance.seriesId,
  'original_date': instance.originalDate,
  'session_id': ?instance.sessionId,
  'actual_duration': ?instance.actualDuration,
  'reason': ?instance.reason,
  'to_date': ?instance.toDate,
  'to_start': ?instance.toStart,
};

OccurrenceNoteDto _$OccurrenceNoteDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'OccurrenceNoteDto',
      json,
      ($checkedConvert) {
        final val = OccurrenceNoteDto(
          seriesId: $checkedConvert('series_id', (v) => v as String),
          originalDate: $checkedConvert('original_date', (v) => v as String),
          note: $checkedConvert('note', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'seriesId': 'series_id',
        'originalDate': 'original_date',
      },
    );

Map<String, dynamic> _$OccurrenceNoteDtoToJson(OccurrenceNoteDto instance) =>
    <String, dynamic>{
      'series_id': instance.seriesId,
      'original_date': instance.originalDate,
      'note': instance.note,
    };

CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'CategoryDto',
  json,
  ($checkedConvert) {
    final val = CategoryDto(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      colorKey: $checkedConvert('color_key', (v) => v as String),
      sortOrder: $checkedConvert('sort_order', (v) => (v as num).toInt()),
      iconKey: $checkedConvert('icon_key', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'colorKey': 'color_key',
    'sortOrder': 'sort_order',
    'iconKey': 'icon_key',
  },
);

Map<String, dynamic> _$CategoryDtoToJson(CategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'color_key': instance.colorKey,
      'icon_key': ?instance.iconKey,
      'sort_order': instance.sortOrder,
    };
