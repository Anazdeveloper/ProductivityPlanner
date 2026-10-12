import 'package:flutter/material.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Shown while the stored session is being restored (usually one frame:
/// restoring reads secure storage only, never the network).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          semanticsLabel: AppLocalizations.of(context).loadingLabel,
        ),
      ),
    );
  }
}
