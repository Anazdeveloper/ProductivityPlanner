import 'package:flutter/material.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Password input with a show/hide toggle. Visibility is purely local UI
/// state, so a StatefulWidget is the right tool (no cubit).
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    required this.onChanged,
    this.fieldKey,
    this.errorText,
    this.helperText,
    this.autofillHints = const [AutofillHints.password],
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.enabled = true,
    super.key,
  });

  final Key? fieldKey;
  final String label;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String? helperText;
  final Iterable<String> autofillHints;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      key: widget.fieldKey,
      obscureText: _obscured,
      enabled: widget.enabled,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          tooltip: _obscured ? l10n.showPassword : l10n.hidePassword,
          icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}
