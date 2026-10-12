import 'package:flutter/material.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Provider buttons, shown only when the provider is available.
///
/// Uses neutral outlined buttons with text labels. Before store submission,
/// swap in the official artwork required by Apple's and Google's branding
/// guidelines (Phase 13 checklist).
class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({
    required this.showApple,
    required this.showGoogle,
    required this.onApple,
    required this.onGoogle,
    this.appleBusy = false,
    this.googleBusy = false,
    this.enabled = true,
    super.key,
  });

  static const appleKey = Key('signIn.apple');
  static const googleKey = Key('signIn.google');

  final bool showApple;
  final bool showGoogle;
  final VoidCallback onApple;
  final VoidCallback onGoogle;
  final bool appleBusy;
  final bool googleBusy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!showApple && !showGoogle) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(l10n.orDivider),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (showApple)
          _ProviderButton(
            key: appleKey,
            label: l10n.continueWithApple,
            icon: Icons.apple,
            busy: appleBusy,
            onPressed: enabled ? onApple : null,
          ),
        if (showApple && showGoogle) const SizedBox(height: AppSpacing.sm),
        if (showGoogle)
          _ProviderButton(
            key: googleKey,
            label: l10n.continueWithGoogle,
            icon: Icons.account_circle_outlined,
            busy: googleBusy,
            onPressed: enabled ? onGoogle : null,
          ),
      ],
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.icon,
    required this.busy,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: busy ? null : onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      icon: busy
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
    );
  }
}
