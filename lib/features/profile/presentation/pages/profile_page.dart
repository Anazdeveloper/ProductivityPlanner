import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:productivity_planner/core/presentation/app_spacing.dart';
import 'package:productivity_planner/core/presentation/widgets/failure_banner.dart';
import 'package:productivity_planner/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

/// Account details and display-name editing. Account deletion and data
/// export arrive in Phase 13. Expects a [ProfileCubit] above it.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const nameFieldKey = Key('profile.name');
  static const saveKey = Key('profile.save');

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // A controller (not cubit state) so a profile refresh from the server does
  // not overwrite what the user is typing.
  final _nameController = TextEditingController();
  bool _nameInitialised = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.savedCount != current.savedCount,
      listener: (context, _) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileSaved))),
      builder: (context, state) {
        final user = state.user;
        if (user != null && !_nameInitialised) {
          _nameController.text = user.displayName;
          _nameInitialised = true;
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n.profileTitle)),
          body: user == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    TextField(
                      key: ProfilePage.nameFieldKey,
                      controller: _nameController,
                      enabled: !state.saving,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.profileNameLabel,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        key: ProfilePage.saveKey,
                        onPressed: state.saving
                            ? null
                            : () => context
                                  .read<ProfileCubit>()
                                  .saveDisplayName(_nameController.text),
                        child: Text(l10n.saveButton),
                      ),
                    ),
                    if (state.failure != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      FailureBanner(failure: state.failure),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.mail_outline),
                      title: Text(l10n.profileEmailLabel),
                      subtitle: Text(user.email),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.public),
                      title: Text(l10n.profileTimeZoneLabel),
                      subtitle: Text(user.timeZone),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
