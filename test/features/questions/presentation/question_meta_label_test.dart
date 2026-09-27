import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/presentation/question_meta_label.dart';

void main() {
  Question question({String? subject}) => Question(
    id: 'q1',
    prompt: 'p',
    options: const ['a', 'b'],
    correctIndex: 0,
    difficulty: QuestionDifficulty.dificil,
    subject: subject,
  );

  test('names the subject and the difficulty when the question has one', () {
    expect(
      questionMetaLabel(question(subject: 'geografia'), AppLanguage.portuguese),
      'Geografia · ${QuestionDifficulty.dificil.label(AppLanguage.portuguese)}',
    );
  });

  test('follows the app language', () {
    expect(
      questionMetaLabel(question(subject: 'matematica'), AppLanguage.english),
      startsWith('Math · '),
    );
  });

  test('is null for a question without a subject (topic decks)', () {
    expect(questionMetaLabel(question(), AppLanguage.portuguese), isNull);
  });
}
