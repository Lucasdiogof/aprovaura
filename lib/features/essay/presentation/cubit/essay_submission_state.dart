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
  const EssaySubmissionLoaded(this.submission);

  final EssaySubmission submission;

  @override
  List<Object?> get props => [submission];
}
