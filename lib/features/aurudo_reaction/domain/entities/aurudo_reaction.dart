import 'package:equatable/equatable.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';

/// A resolved reaction: the one main animation to play, plus whatever
/// other achievements happened in the same event, to show as badges.
class AurudoReaction extends Equatable {
  const AurudoReaction({
    required this.type,
    this.secondary = const [],
    this.essayTier,
  });

  final AurudoReactionType type;
  final List<AurudoSecondaryAchievement> secondary;

  /// Only meaningful when [type] is
  /// [AurudoReactionType.correctionReady] -- the essay score band the
  /// mascot's pose is picked from (see `AurudoMascotView`). Null for
  /// every other reaction type; the resolver always sets it when it
  /// builds a `correctionReady` reaction.
  final EssayReactionTier? essayTier;

  @override
  List<Object?> get props => [type, secondary, essayTier];
}
