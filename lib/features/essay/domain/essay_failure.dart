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

/// Why the server refused to freeze a draft into an attempt.
///
/// [textTooShort] and [noDraft] are the two refusals `submit_essay_draft`
/// raises by name; flattening them into one generic failure was how a
/// person writing thirty words ended up reading "não conseguimos enviar"
/// with no idea that length was the problem.
enum EssaySubmitFailureKind {
  /// Under essay_min_word_count() words (P0003). The draft is untouched.
  textTooShort,

  /// Nothing to submit: the draft is empty or already gone (P0002).
  noDraft,

  /// Anything else -- no connection, an unknown code, a timeout.
  unexpected,
}

class EssaySubmitFailure extends Failure {
  const EssaySubmitFailure(this.kind) : super('');

  /// Maps the errcodes raised by submit_essay_draft (essays.sql, 3.2).
  /// Only codes this app put there are recognised; anything else stays
  /// [EssaySubmitFailureKind.unexpected] rather than being guessed at.
  factory EssaySubmitFailure.fromCode(String? code) => switch (code) {
    'P0003' => const EssaySubmitFailure(EssaySubmitFailureKind.textTooShort),
    'P0002' => const EssaySubmitFailure(EssaySubmitFailureKind.noDraft),
    _ => const EssaySubmitFailure(EssaySubmitFailureKind.unexpected),
  };

  final EssaySubmitFailureKind kind;

  @override
  List<Object?> get props => [kind];
}
