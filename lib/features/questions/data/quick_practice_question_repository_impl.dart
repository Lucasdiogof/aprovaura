import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';

/// Questions the user has never answered, one per subject per round (see
/// `supabase/quick_practice.sql`).
///
/// Same rows and same shape as [QuestionRepositoryImpl], so the shared quiz
/// engine doesn't know the difference -- and because the deck is just
/// ordinary questions, answering them already counts toward their own
/// topic's progress and already feeds "revisar erros".
///
/// `catalogNodeId` and `difficulty` are ignored: a quick-practice deck
/// spans the whole catalog and every level. They stay in the signature to
/// satisfy [QuestionRepository], the same way review sessions ignore
/// difficulty.
class QuickPracticeQuestionRepositoryImpl implements QuestionRepository {
  QuickPracticeQuestionRepositoryImpl(this._client, this._localeCubit);

  /// How many questions one round of quick practice serves.
  static const deckSize = 10;

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;

  @override
  Future<Result<List<Question>>> getQuestions(
    String catalogNodeId, {
    QuestionDifficulty? difficulty,
  }) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'get_quick_practice_questions',
        params: {
          'p_limit': deckSize,
          'p_locale': _localeCubit.state.databaseLocale,
        },
      );
      final questions = rows
          .cast<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
      return Success(questions);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  Question _fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
    correctIndex: json['correct_index'] as int,
    explanation: json['explanation'] as String?,
    difficulty: QuestionDifficulty.fromDb(json['difficulty'] as String?),
  );
}
