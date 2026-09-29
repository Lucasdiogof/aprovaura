import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/data/aurudo_reaction_ledger.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/pending_home_reaction.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Streak _streak(int days) => Streak(
  currentStreak: days,
  longestStreak: days,
  streakBreakVersion: 0,
  seenStreakBreakVersion: 0,
);

final _today = DateTime(2026, 9, 29);

/// What Home should celebrate when it opens.
///
/// Almost always nothing: a result screen marks whatever it showed, so
/// coming back to Home only updates numbers. The one real gap it covers
/// is the daily goal reached in the middle of a mock exam, which the
/// exam's own result refuses to claim.
void main() {
  late AuthRepository authRepository;
  late SharedPreferences prefs;

  Future<void> signIn(String userId) async {
    when(
      () => authRepository.currentUser,
    ).thenReturn(AppUser(id: userId, email: '$userId@example.com'));
  }

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    authRepository = _MockAuthRepository();
    sl.registerLazySingleton<AuthRepository>(() => authRepository);
    sl.registerSingleton<SharedPreferences>(prefs);
    await signIn('user-1');
  });

  AurudoReactionLedger ledgerFor(String userId) =>
      AurudoReactionLedger(prefs, userId: userId);

  PendingHomeReaction? pendingFor({
    int totalXp = 0,
    int streakDays = 1,
    int answered = 0,
  }) => pendingHomeReaction(
    xp: UserXp(totalXp: totalXp),
    streak: _streak(streakDays),
    dailyGoal: DailyGoal(answered: answered),
    today: _today,
  );

  group('the first look at a user', () {
    test('writes the standing down instead of celebrating it', () {
      // A fresh install of someone already at level 8 with a 30-day
      // streak: none of that just happened.
      expect(pendingFor(totalXp: 720, streakDays: 30, answered: 12), isNull);

      final ledger = ledgerFor('user-1');
      expect(ledger.hasBaseline, isTrue);
      expect(ledger.hasCelebratedLevel(8), isTrue);
      expect(ledger.hasCelebratedStreakMilestone(30), isTrue);
      expect(ledger.hasCelebratedDailyGoal(_today), isTrue);
    });

    test('and only what grows past it is news', () {
      pendingFor(totalXp: 690, streakDays: 6, answered: 3);

      final pending = pendingFor(totalXp: 720, streakDays: 6, answered: 3);
      expect(pending?.reaction.type, AurudoReactionType.levelUp);
    });
  });

  group('nothing to celebrate', () {
    setUp(() => pendingFor());

    test('when the numbers have not moved', () {
      expect(pendingFor(), isNull);
    });

    test('when a result screen already marked the achievement', () {
      // Exactly what a quiz or a map does when it shows the badge.
      ledgerFor('user-1').markLevelCelebrated(8);
      expect(pendingFor(totalXp: 720), isNull);
    });

    test('when the streak milestone was already shown', () {
      ledgerFor('user-1').markStreakMilestoneCelebrated(7);
      expect(pendingFor(streakDays: 7), isNull);
    });

    test('when the goal was already celebrated today', () {
      ledgerFor('user-1').markDailyGoalCelebrated(_today);
      expect(pendingFor(answered: 12), isNull);
    });

    test('while any of the numbers is still loading', () {
      expect(
        pendingHomeReaction(
          xp: null,
          streak: _streak(7),
          dailyGoal: const DailyGoal(answered: 12),
          today: _today,
        ),
        isNull,
      );
      expect(
        pendingHomeReaction(
          xp: const UserXp(totalXp: 10),
          streak: null,
          dailyGoal: const DailyGoal(answered: 12),
          today: _today,
        ),
        isNull,
      );
      expect(
        pendingHomeReaction(
          xp: const UserXp(totalXp: 10),
          streak: _streak(7),
          dailyGoal: null,
          today: _today,
        ),
        isNull,
      );
    });

    test('a streak between milestones is just a number', () {
      expect(pendingFor(streakDays: 6), isNull);
    });
  });

  group('the fallback', () {
    setUp(() => pendingFor());

    test('picks up a daily goal nobody claimed', () {
      // The goal reached on question 10 of a 30-question exam: the exam's
      // result deliberately does not claim it.
      final pending = pendingFor(answered: 12);

      expect(pending?.reaction.type, AurudoReactionType.dailyGoalComplete);
    });

    test('only once -- the next look finds nothing', () {
      pendingFor(answered: 12)!.markCelebrated();

      expect(pendingFor(answered: 12), isNull);
    });

    test('survives a restart, because the ledger is on disk', () {
      pendingFor(answered: 12)!.markCelebrated();

      // A new ledger over the same storage, as a fresh launch would build.
      expect(ledgerFor('user-1').hasCelebratedDailyGoal(_today), isTrue);
      expect(pendingFor(answered: 12), isNull);
    });

    test('picks up a genuinely new level', () {
      final pending = pendingFor(totalXp: 720);

      expect(pending?.reaction.type, AurudoReactionType.levelUp);
      expect(pending?.reaction.secondary.single.value, 8);
    });

    test('picks up a milestone the day it is reached', () {
      final pending = pendingFor(streakDays: 7);

      expect(pending?.reaction.type, AurudoReactionType.streakMilestone);
      expect(pending?.reaction.secondary.single.value, 7);
    });

    test('shows one reaction even when three things are pending', () {
      final pending = pendingFor(totalXp: 720, streakDays: 7, answered: 12);

      // Level outranks streak outranks goal.
      expect(pending?.reaction.type, AurudoReactionType.levelUp);

      // And the others are not lost -- they simply wait their turn rather
      // than playing three scenes at once.
      pending!.markCelebrated();
      final next = pendingFor(totalXp: 720, streakDays: 7, answered: 12);
      expect(next?.reaction.type, AurudoReactionType.streakMilestone);
    });
  });

  group('two people on one device', () {
    test('what one celebrated does not silence the other', () async {
      pendingFor();
      pendingFor(totalXp: 720)!.markCelebrated();
      expect(pendingFor(totalXp: 720), isNull);

      await signIn('user-2');
      // Their own first look is a baseline, not a party...
      expect(pendingFor(totalXp: 690), isNull);
      // ...and then their level 8 is theirs to celebrate.
      expect(
        pendingFor(totalXp: 720)?.reaction.type,
        AurudoReactionType.levelUp,
      );
    });

    test('nobody signed in means nothing to celebrate', () {
      when(() => authRepository.currentUser).thenReturn(null);
      expect(pendingFor(totalXp: 720), isNull);
    });
  });
}
