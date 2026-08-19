import 'package:equatable/equatable.dart';

class UserXp extends Equatable {
  const UserXp({required this.totalXp});

  static const initial = UserXp(totalXp: 0);

  static const _xpPerLevel = 100;

  final int totalXp;

  int get level => (totalXp ~/ _xpPerLevel) + 1;
  int get xpIntoLevel => totalXp % _xpPerLevel;
  int get xpForNextLevel => _xpPerLevel;
  double get levelProgress => xpIntoLevel / xpForNextLevel;

  @override
  List<Object?> get props => [totalXp];
}
