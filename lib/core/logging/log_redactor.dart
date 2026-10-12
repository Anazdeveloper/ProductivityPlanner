/// Keys whose values must never reach logs or error reports.
/// Matches the server's pino redaction list (approved design, section 13).
const Set<String> sensitiveLogKeys = {
  'authorization',
  'password',
  'token',
  'access_token',
  'refresh_token',
  'id_token',
  'email',
  'title',
  'description',
  'notes',
  'note',
  'transcript',
  'display_name',
};

const _redacted = '[redacted]';

/// Returns a copy of [context] with sensitive values replaced. Nested maps
/// are redacted too. Key matching ignores case and `-`/`_` differences.
Map<String, Object?> redactLogContext(Map<String, Object?> context) => {
  for (final entry in context.entries)
    entry.key: _isSensitive(entry.key)
        ? _redacted
        : switch (entry.value) {
            final Map<String, Object?> nested => redactLogContext(nested),
            final other => other,
          },
};

bool _isSensitive(String key) =>
    sensitiveLogKeys.contains(key.toLowerCase().replaceAll('-', '_'));
