import 'package:aura/core/error/failures.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';

/// Carries an [EssayEvaluationFailure] through the app's Result type, so
/// the UI can say something specific ("o limite de hoje acabou") instead of
/// one generic sentence for every way a marking can fail.
class EssayEvaluationFailureWrapper extends Failure {
  const EssayEvaluationFailureWrapper(this.kind) : super('');

  final EssayEvaluationFailure kind;

  @override
  List<Object?> get props => [kind];
}
