import 'package:aura/core/error/result.dart';

abstract class QuestionReportRepository {
  Future<Result<void>> reportQuestion({
    required String questionId,
    required String questionPrompt,
  });
}
