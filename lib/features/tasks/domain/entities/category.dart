import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// Colours a category can use. Keys, not colours: the theme maps each key to
/// a light and a dark shade.
enum CategoryColor { blue, purple, green, orange, red, teal, pink, grey }

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required CategoryColor color,
    String? iconKey,
    @Default(0) int sortOrder,

    /// Seeded on sign-in with a deterministic id (same on every device).
    @Default(false) bool isDefault,
    @Default(0) int version,
  }) = _Category;
}
