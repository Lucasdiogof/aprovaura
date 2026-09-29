import 'package:equatable/equatable.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';

/// A resolved reaction: the one main animation to play, plus whatever
/// other achievements happened in the same event, to show as badges.
class AurudoReaction extends Equatable {
  const AurudoReaction({required this.type, this.secondary = const []});

  final AurudoReactionType type;
  final List<AurudoSecondaryAchievement> secondary;

  @override
  List<Object?> get props => [type, secondary];
}
