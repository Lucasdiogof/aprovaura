import 'package:equatable/equatable.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';

sealed class ErrorReviewState extends Equatable {
  const ErrorReviewState();

  @override
  List<Object?> get props => [];
}

class ErrorReviewLoading extends ErrorReviewState {
  const ErrorReviewLoading();
}

class ErrorReviewError extends ErrorReviewState {
  const ErrorReviewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ErrorReviewLoaded extends ErrorReviewState {
  const ErrorReviewLoaded(this.topics);

  final List<ErrorTopic> topics;

  @override
  List<Object?> get props => [topics];
}
