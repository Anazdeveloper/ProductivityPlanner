import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';

/// One piece of a stacked bar.
@immutable
final class BarSegment {
  const BarSegment({
    required this.value,
    required this.color,
    this.outlined = false,
  });

  final double value;
  final Color color;

  /// Drawn as an outline: for things not yet decided (still to do, planned
  /// time), so they read as "not done" without relying on colour.
  final bool outlined;

  @override
  bool operator ==(Object other) =>
      other is BarSegment &&
      other.value == value &&
      other.color == color &&
      other.outlined == outlined;

  @override
  int get hashCode => Object.hash(value, color, outlined);
}

/// One x-axis position: one or more bars side by side, each a stack of
/// segments, plus an optional reference line (e.g. the planned duration).
@immutable
final class BarGroup {
  const BarGroup({
    required this.label,
    required this.semanticLabel,
    required this.bars,
    this.marker,
  });

  /// Under the group; may be empty to thin out a crowded axis.
  final String label;

  /// Everything the group shows, in words (screen readers).
  final String semanticLabel;
  final List<List<BarSegment>> bars;
  final double? marker;

  double get maxValue {
    var max = marker ?? 0;
    for (final bar in bars) {
      final total = bar.fold<double>(0, (sum, s) => sum + s.value);
      if (total > max) max = total;
    }
    return max;
  }

  @override
  bool operator ==(Object other) =>
      other is BarGroup &&
      other.label == label &&
      other.semanticLabel == semanticLabel &&
      other.marker == marker &&
      other.bars.length == bars.length &&
      [
        for (var i = 0; i < bars.length; i++) listEquals(other.bars[i], bars[i]),
      ].every((same) => same);

  @override
  int get hashCode => Object.hash(
    label,
    semanticLabel,
    marker,
    Object.hashAll([for (final bar in bars) Object.hashAll(bar)]),
  );
}

/// A y-axis scale with round steps.
@immutable
final class ChartScale {
  const ChartScale({required this.max, required this.step});

  /// The smallest scale from [steps] (ascending) that fits [value] in at
  /// most [maxTicks] steps. An empty chart still gets one step.
  factory ChartScale.fit(
    double value, {
    required List<double> steps,
    int maxTicks = 4,
  }) {
    for (final step in steps) {
      final count = math.max(1, (value / step).ceil());
      if (count <= maxTicks) return ChartScale(max: count * step, step: step);
    }
    final step = steps.last;
    return ChartScale(max: math.max(1, (value / step).ceil()) * step, step: step);
  }

  final double max;
  final double step;

  List<double> get ticks => [
    for (var v = 0.0; v <= max + step / 1000; v += step) v,
  ];

  @override
  bool operator ==(Object other) =>
      other is ChartScale && other.max == max && other.step == step;

  @override
  int get hashCode => Object.hash(max, step);
}

/// A small bar chart: stacked or side-by-side bars per group, a y-axis
/// with round steps, and one semantics node per group so screen-reader
/// users get the same numbers. Tapping a group calls [onTapGroup].
///
/// Hand-drawn rather than a chart package: the app needs bar charts only,
/// and this keeps accessibility and theming under our control.
class BarChart extends StatelessWidget {
  const BarChart({
    required this.groups,
    required this.scale,
    required this.axisLabel,
    this.markerColor,
    this.onTapGroup,
    this.height = 160,
    this.groupKeyPrefix,
    super.key,
  });

  static const double _axisWidth = 36;

  final List<BarGroup> groups;
  final ChartScale scale;
  final String Function(double value) axisLabel;
  final Color? markerColor;
  final ValueChanged<int>? onTapGroup;
  final double height;

  /// Keys the tap target of group `i` as `'$groupKeyPrefix$i'` (tests).
  final String? groupKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final onTap = onTapGroup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: SizedBox(
                  width: _axisWidth,
                  child: CustomPaint(
                    painter: _AxisPainter(
                      scale: scale,
                      labels: [for (final t in scale.ticks) axisLabel(t)],
                      style: labelStyle ?? const TextStyle(fontSize: 11),
                      textDirection: Directionality.of(context),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _BarsPainter(
                        groups: groups,
                        scale: scale,
                        gridColor: theme.colorScheme.outlineVariant,
                        markerColor:
                            markerColor ?? theme.colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < groups.length; i++)
                          Expanded(
                            child: Semantics(
                              key: groupKeyPrefix == null
                                  ? null
                                  : Key('$groupKeyPrefix$i'),
                              label: groups[i].semanticLabel,
                              button: onTap != null,
                              onTap: onTap == null ? null : () => onTap(i),
                              excludeSemantics: true,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: onTap == null ? null : () => onTap(i),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: _axisWidth),
            child: Row(
              children: [
                for (final group in groups)
                  Expanded(
                    child: Text(
                      group.label,
                      style: labelStyle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A row of colour keys under a chart.
class ChartLegend extends StatelessWidget {
  const ChartLegend({required this.items, super.key});

  final List<({String label, Color color, bool outlined})> items;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.outlined ? null : item.color,
                  border: item.outlined
                      ? Border.all(color: item.color, width: 1.5)
                      : null,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(item.label, style: style),
            ],
          ),
      ],
    );
  }
}

class _AxisPainter extends CustomPainter {
  _AxisPainter({
    required this.scale,
    required this.labels,
    required this.style,
    required this.textDirection,
  });

  final ChartScale scale;
  final List<String> labels;
  final TextStyle style;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final ticks = scale.ticks;
    for (var i = 0; i < ticks.length && i < labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(text: labels[i], style: style),
        textDirection: textDirection,
        maxLines: 1,
      )..layout(maxWidth: size.width - 4);
      final y = size.height - ticks[i] / scale.max * size.height;
      final offset = Offset(
        size.width - 4 - painter.width,
        (y - painter.height / 2)
            .clamp(0, math.max(0, size.height - painter.height))
            .toDouble(),
      );
      painter
        ..paint(canvas, offset)
        ..dispose();
    }
  }

  @override
  bool shouldRepaint(_AxisPainter old) =>
      old.scale != scale ||
      !listEquals(old.labels, labels) ||
      old.style != style;
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.groups,
    required this.scale,
    required this.gridColor,
    required this.markerColor,
  });

  final List<BarGroup> groups;
  final ChartScale scale;
  final Color gridColor;
  final Color markerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final tick in scale.ticks) {
      final y = _y(tick, size);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    if (groups.isEmpty) return;

    final slot = size.width / groups.length;
    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      final count = math.max(1, group.bars.length);
      final barWidth = math.min(slot * 0.7 / count, 22).toDouble();
      final groupWidth = barWidth * count + (count - 1) * 2;
      var left = slot * i + (slot - groupWidth) / 2;
      for (final bar in group.bars) {
        _paintBar(canvas, size, bar, left, barWidth);
        left += barWidth + 2;
      }
      if (group.marker case final marker?) {
        final y = _y(marker, size);
        final inset = slot * 0.1;
        canvas.drawLine(
          Offset(slot * i + inset, y),
          Offset(slot * (i + 1) - inset, y),
          Paint()
            ..color = markerColor
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _paintBar(
    Canvas canvas,
    Size size,
    List<BarSegment> segments,
    double left,
    double width,
  ) {
    var base = 0.0;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final top = base + segment.value;
      final rect = Rect.fromLTRB(left, _y(top, size), left + width, _y(base, size));
      final shape = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      if (segment.outlined) {
        canvas.drawRRect(
          shape.deflate(0.75),
          Paint()
            ..color = segment.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      } else {
        canvas.drawRRect(shape, Paint()..color = segment.color);
      }
      base = top;
    }
  }

  double _y(double value, Size size) {
    final ratio = scale.max <= 0
        ? 0.0
        : (value / scale.max).clamp(0, 1).toDouble();
    return size.height - ratio * size.height;
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      !listEquals(old.groups, groups) ||
      old.scale != scale ||
      old.gridColor != gridColor ||
      old.markerColor != markerColor;
}
