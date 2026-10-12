import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the Clean Architecture dependency rules by reading every import
/// in lib/. Runs as part of `flutter test`, so a violating PR fails CI.
///
/// Must be run from the package root (as `flutter test` does).
void main() {
  const package = 'package:productivity_planner/';

  final sources = _dartSources('lib');

  test('scans the project (guards against running from the wrong folder)', () {
    expect(sources, isNotEmpty);
  });

  test('lib uses package imports only, so the rules below see every edge', () {
    final violations = <String>[
      for (final file in sources)
        for (final uri in file.imports)
          if (!uri.startsWith('package:') && !uri.startsWith('dart:'))
            '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('domain code is pure Dart: no Flutter, IO, packages or outer layers', () {
    const forbiddenPrefixes = [
      'package:flutter/',
      'package:flutter_bloc/',
      'package:bloc/',
      'package:go_router/',
      'package:get_it/',
      'package:dio/',
      'package:drift/',
      'package:firebase_',
      'package:flutter_local_notifications/',
      'package:purchases_flutter/',
      'package:speech_to_text/',
      'package:connectivity_plus/',
      'dart:ui',
      'dart:io',
    ];
    final violations = <String>[
      for (final file in sources.where((f) => f.isPureDart))
        for (final uri in file.imports)
          if (forbiddenPrefixes.any(uri.startsWith) ||
              uri.contains('/data/') ||
              uri.contains('/presentation/') ||
              uri.startsWith('${package}config/'))
            '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation never reaches the data layer, HTTP, the database or platform plugins', () {
    const forbiddenPrefixes = [
      'package:dio/',
      'package:drift/',
      'package:http/',
      'package:speech_to_text/',
      'package:purchases_flutter/',
      'package:connectivity_plus/',
      '${package}core/network/',
    ];
    final violations = <String>[
      for (final file in sources.where((f) => f.layer == _Layer.presentation))
        for (final uri in file.imports)
          if (uri.contains('/data/') || forbiddenPrefixes.any(uri.startsWith))
            '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('features only use other features through their domain layer', () {
    final violations = <String>[
      for (final file in sources.where((f) => f.feature != null))
        for (final uri in file.imports)
          if (_featureOf(uri.replaceFirst(package, 'lib/'))
              case final other?
              when other != file.feature &&
                  (uri.contains('$other/data/') ||
                      uri.contains('$other/presentation/')))
            '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('core does not depend on features or the composition root', () {
    final violations = <String>[
      for (final file in sources.where((f) => f.path.startsWith('lib/core/')))
        for (final uri in file.imports)
          if (uri.startsWith('${package}features/') ||
              uri.startsWith('${package}config/'))
            '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('features import the composition root only from registrars', () {
    final violations = <String>[
      for (final file in sources.where(
        (f) => f.feature != null && !f.path.endsWith('_dependencies.dart'),
      ))
        for (final uri in file.imports)
          if (uri.startsWith('${package}config/')) '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('only the database core and data layers use drift', () {
    final violations = <String>[
      for (final file in sources)
        if (!file.path.startsWith('lib/core/database/') &&
            !file.path.startsWith('lib/core/sync/') &&
            file.layer != _Layer.data)
          for (final uri in file.imports)
            if (uri.startsWith('package:drift'))
              '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('only core/timezone uses the tz database package', () {
    final violations = <String>[
      for (final file in sources)
        if (!file.path.startsWith('lib/core/timezone/'))
          for (final uri in file.imports)
            if (uri.startsWith('package:timezone/'))
              '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('only config/ and feature registrars touch the service locator', () {
    final violations = <String>[
      for (final file in sources)
        if (!file.path.startsWith('lib/config/') &&
            !file.path.endsWith('_dependencies.dart'))
          for (final uri in file.imports)
            if (uri.startsWith('package:get_it/') ||
                uri == '${package}config/di/injection.dart')
              '${file.path} -> $uri',
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

enum _Layer { domain, data, presentation, other }

/// Core folders that must stay framework-free because domain code uses them.
const _pureDartCoreDirs = [
  'lib/core/error/',
  'lib/core/result/',
  'lib/core/usecase/',
  'lib/core/time/',
  'lib/core/entitlements/',
  'lib/core/ids/',
];

final class _SourceFile {
  _SourceFile(this.path, this.imports);

  final String path;
  final List<String> imports;

  String? get feature => _featureOf(path);

  _Layer get layer {
    if (path.contains('/domain/')) return _Layer.domain;
    if (path.contains('/data/')) return _Layer.data;
    if (path.contains('/presentation/')) return _Layer.presentation;
    return _Layer.other;
  }

  bool get isPureDart =>
      (feature != null && layer == _Layer.domain) ||
      _pureDartCoreDirs.any(path.startsWith);
}

String? _featureOf(String path) {
  final match = RegExp('^lib/features/([a-z0-9_]+)/').firstMatch(path);
  return match?.group(1);
}

final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<_SourceFile> _dartSources(String root) {
  final dir = Directory(root);
  if (!dir.existsSync()) return const [];
  return [
    for (final entity in dir.listSync(recursive: true))
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          !entity.path.endsWith('.g.dart') &&
          !entity.path.endsWith('.freezed.dart') &&
          !entity.path.replaceAll(r'\', '/').contains('lib/l10n/generated/'))
        _SourceFile(
          entity.path.replaceAll(r'\', '/'),
          [
            for (final m in _directive.allMatches(entity.readAsStringSync()))
              m.group(1) ?? '',
          ],
        ),
  ];
}
