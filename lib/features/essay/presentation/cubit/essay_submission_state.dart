import 'package:equatable/equatable.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';

sealed class EssaySubmissionState extends Equatable {
  const EssaySubmissionState();

  @override
  List<Object?> get props => [];
}

class EssaySubmissionLoading extends EssaySubmissionState {
  const EssaySubmissionLoading();
}

class EssaySubmissionError extends EssaySubmissionState {
  const EssaySubmissionError();
}

class EssaySubmissionLoaded extends EssaySubmissionState {
  const EssaySubmissionLoaded(
    this.submission, {
    this.isRequesting = false,
    this.failure,
  });

  final EssaySubmission submission;

  /// A marking was asked for and the server has not answered yet.
  final bool isRequesting;

  /// Why the last request could not go through. Separate from the
  /// attempt's own status: the text is safe either way, and this only says
  /// whether it is worth trying again now.
  final EssayEvaluationFailure? failure;

  EssaySubmissionLoaded copyWith({
    EssaySubmission? submission,
    bool? isRequesting,
    EssayEvaluationFailure? failure,
    bool clearFailure = false,
  }) => EssaySubmissionLoaded(
    submission ?? this.submission,
    isRequesting: isRequesting ?? this.isRequesting,
    failure: clearFailure ? null : (failure ?? this.failure),
  );

  @override
  List<Object?> get props => [submission, isRequesting, failure];
}
