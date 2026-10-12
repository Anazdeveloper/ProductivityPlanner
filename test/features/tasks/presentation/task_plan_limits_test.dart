import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_planner/config/theme/app_theme.dart';
import 'package:productivity_planner/core/entitlements/feature.dart';
import 'package:productivity_planner/core/time/local_date.dart';
import 'package:productivity_planner/features/tasks/presentation/bloc/task_editor_cubit.dart';
import 'package:productivity_planner/features/tasks/presentation/pages/task_editor_page.dart';
import 'package:productivity_planner/l10n/generated/app_localizations.dart';

import '../../../helpers/agenda_builders.dart';
import '../../../helpers/fake_feature_access.dart';
import '../../../helpers/fake_task_repository.dart';
import '../../../helpers/fakes.dart';

void main() {
  testWidgets('a plan limit stops the save and offers the plans', (
    tester,
  ) async {
    final tasks = FakeTaskRepository([
      agendaItem(id: 'existing', date: LocalDate(2026, 10, 7)),
    ]);
    final factory = TaskCubitFactory(
      tasks: tasks,
      clock: FixedClock(DateTime.utc(2026, 10, 7, 4, 30)),
      access: const FakeFeatureAccess(limits: {LimitKey.activeSeries: 1}),
    );
    var plansOpened = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider(
          create: (_) =>
              factory.editor(const TaskEditorArgs.create(title: 'Read'))
                ..load(),
          child: TaskEditorPage(
            onClose: () {},
            onSaved: () {},
            onOpenPlans: () => plansOpened++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(TaskEditorPage.saveKey));
    await tester.pumpAndSettle();

    expect(tasks.created, isEmpty);
    expect(
      find.text(
        'Your plan includes 1 active task. End one or upgrade to add more.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('See plans'));
    expect(plansOpened, 1);
  });
}
