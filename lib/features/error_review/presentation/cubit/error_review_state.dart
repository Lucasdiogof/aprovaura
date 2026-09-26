import 'package:equatable/equatable.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';

/// Every state carries [source] (null = every pending error, 'practice',
/// or 'mock_exam') so the selector pill can stay drawn -- and keep
/// showing the right selection -- through loading and error states too,
/// not just once topics have loaded.
sealed class ErrorReviewState extends Equatable {
  const ErrorReviewState(this.source);

  final String? source;

  @override
  List<Object?> get props => [source];
}

class ErrorReviewLoading extends ErrorReviewState {
  const ErrorReviewLoading([super.source]);
}

class ErrorReviewError extends ErrorReviewState {
  const ErrorReviewError(this.message, [super.source]);

  final String message;

  @override
  List<Object?> get props => [source, message];
}

class ErrorReviewLoaded extends ErrorReviewState {
  const ErrorReviewLoaded(this.topics, [super.source]);

  final List<ErrorTopic> topics;

  @override
  List<Object?> get props => [source, topics];
}
