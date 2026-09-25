import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/pages/essay_themes_page.dart';
import 'package:aura/features/practice/presentation/pages/practice_page.dart';
import 'package:aura/features/profile/domain/entities/user_profile.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_tile.dart';
import 'package:aura/shared/widgets/aura_sparkle_burst.dart';

import '../../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({this.initialFocus = const []});

  final List<Subject> initialFocus;

  @override
  Future<Result<UserProfile>> getCurrent() async =>
      Success(UserProfile(id: 'u1', interestedSubjects: initialFocus));
  @override
  Future<Result<UserProfile>> createProfile({
    required String id,
    required String name,
    String? username,
  }) => throw UnimplementedError();
  @override
  Future<Result<void>> updateProfile({
    String? name,
    String? username,
    dynamic goal,
    String? examYear,
    List<Subject>? interestedSubjects,
  }) => throw UnimplementedError();
}

void main() {
  late EssayRepository essayRepository;

  setUp(() async {
    await sl.reset();
    essayRepository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => essayRepository);
    when(
      () => essayRepository.listThemes(),
    ).thenAnswer((_) async => const Success(<EssayThemeSummary>[]));
  });

  // No subject is "em foco" here -- these tests only care that the grid
  // itself still works, not about the focus state, which has its own tests.
  List<BlocProvider<dynamic>> providers() => [
    BlocProvider<ProfileCubit>(
      create: (_) => ProfileCubit(
        _FakeProfileRepository(),
        const AppUser(id: 'u1', email: 'a@example.com'),
      ),
    ),
  ];

  group(PracticePage, () {
    testWidgets('shows every subject plus Redação', (tester) async {
      await tester.pumpApp(const PracticePage(), providers: providers());
      await tester.pumpAndSettle();

      // The grid builds lazily, so this checks both ends of it instead of
      // counting tiles that were never built.
      expect(
        find.text(Subject.values.first.label(AppLanguage.portuguese)),
        findsOneWidget,
      );
      expect(find.byType(SubjectTile), findsWidgets);

      await tester.scrollUntilVisible(find.text('Redação'), 300);
      expect(find.text('Redação'), findsOneWidget);
    });

    testWidgets('Redação opens its own route, not the catalog', (tester) async {
      await tester.pumpApp(const PracticePage(), providers: providers());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Redação'), 300);
      await tester.tap(find.text('Redação'));
      await tester.pumpAndSettle();

      expect(find.byType(EssayThemesPage), findsOneWidget);
    });

    testWidgets('nothing in the grid claims a percentage', (tester) async {
      await tester.pumpApp(const PracticePage(), providers: providers());
      await tester.pumpAndSettle();

      // Essays have no progress to show, and the subject tiles never had
      // one either -- so a bar anywhere here would be invented.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('matérias em foco', () {
    testWidgets(
      'a subject already in focus when the tab opens never sparkles',
      (tester) async {
        final profileCubit = ProfileCubit(
          _FakeProfileRepository(initialFocus: [Subject.matematica]),
          const AppUser(id: 'u1', email: 'a@example.com'),
        );
        await tester.pumpApp(
          const PracticePage(),
          providers: [BlocProvider<ProfileCubit>.value(value: profileCubit)],
        );
        await tester.pumpAndSettle();

        // matematica was already focused the first time this profile was
        // ever seen -- there is no prior "out of focus" build to compare
        // against, so this must not read as a live transition.
        expect(find.byType(AuraSparkleBurst), findsNothing);
      },
    );

    testWidgets(
      'a subject that becomes focused while the tab is open sparkles once',
      (tester) async {
        final profileCubit = ProfileCubit(
          _FakeProfileRepository(),
          const AppUser(id: 'u1', email: 'a@example.com'),
        );
        await tester.pumpApp(
          const PracticePage(),
          providers: [BlocProvider<ProfileCubit>.value(value: profileCubit)],
        );
        await tester.pumpAndSettle();
        // Establish the "no focus" baseline first.
        profileCubit.applyInterestedSubjects(const []);
        await tester.pumpAndSettle();

        profileCubit.applyInterestedSubjects([Subject.matematica]);
        // The cubit's own emit is a microtask; one pump only starts the
        // frame that reacts to it, a second pump renders that reaction.
        await tester.pump();
        await tester.pump();

        expect(find.byType(AuraSparkleBurst), findsOneWidget);
        await tester.pumpAndSettle();

        // A later rebuild that adds a *different* subject to focus plays
        // the sparkle for that one, not a replay for matematica -- its own
        // transition already happened and is done.
        profileCubit.applyInterestedSubjects([
          Subject.matematica,
          Subject.geografia,
        ]);
        await tester.pump();
        await tester.pump();

        expect(find.byType(AuraSparkleBurst), findsOneWidget);
        final matematicaTile = tester.widget<SubjectTile>(
          find
              .ancestor(
                of: find.text('Matemática'),
                matching: find.byType(SubjectTile),
              )
              .first,
        );
        expect(matematicaTile.justEnteredFocus, isFalse);
      },
    );
  });
}
