import 'package:equatable/equatable.dart';

class UserXp extends Equatable {
  const UserXp({required this.totalXp});

  static const initial = UserXp(totalXp: 0);

  /// Aura granted per correct answer, mirroring award_quiz_xp() in
  /// `supabase/quiz_xp_ledger.sql`. The server is the source of truth --
  /// this is only so result screens can show what was just earned without
  /// a second round trip.
  static const auraPerCorrectAnswer = 10;

  static const _xpPerLevel = 100;

  final int totalXp;

  int get level => (totalXp ~/ _xpPerLevel) + 1;
  int get xpIntoLevel => totalXp % _xpPerLevel;
  int get xpForNextLevel => _xpPerLevel;
  double get levelProgress => xpIntoLevel / xpForNextLevel;

  @override
  List<Object?> get props => [totalXp];
}
