import 'package:equatable/equatable.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';

/// Every state carries [source] (null = every pending error, 'practice',
/// or 'mock_exam') and [hasMockExamErrors] so the selector pill can stay
/// drawn (or stay hidden) with the right selection through loading and
/// error states too, not just once topics have loaded.
sealed class ErrorReviewState extends Equatable {
  const ErrorReviewState(this.source, this.hasMockExamErrors);

  final String? source;

  /// Whether there is at least one pending error from a mock exam, right
  /// now -- the Prática/Simulados split only makes sense to show once
  /// there is something to actually split; a person who never took a
  /// mock exam (or already resolved all of those errors) just sees the
  /// plain list, no tabs offering an empty second option.
  final bool hasMockExamErrors;

  @override
  List<Object?> get props => [source, hasMockExamErrors];
}

class ErrorReviewLoading extends ErrorReviewState {
  const ErrorReviewLoading([super.source, super.hasMockExamErrors = false]);
}

class ErrorReviewError extends ErrorReviewState {
  const ErrorReviewError(
    this.message, [
    super.source,
    super.hasMockExamErrors = false,
  ]);

  final String message;

  @override
  List<Object?> get props => [source, hasMockExamErrors, message];
}

class ErrorReviewLoaded extends ErrorReviewState {
  const ErrorReviewLoaded(
    this.topics, [
    super.source,
    super.hasMockExamErrors = false,
  ]);

  final List<ErrorTopic> topics;

  @override
  List<Object?> get props => [source, hasMockExamErrors, topics];
}
