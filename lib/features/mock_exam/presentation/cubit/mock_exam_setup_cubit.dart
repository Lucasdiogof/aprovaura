import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_quantity.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_setup_state.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

/// What happened when the user confirmed "Começar simulado". Returned
/// instead of emitted, so the page reacts exactly once (navigate / open a
/// sheet) without a one-shot flag living in the state.
sealed class MockExamSubmitResult {
  const MockExamSubmitResult();
}

class MockExamCreated extends MockExamSubmitResult {
  const MockExamCreated(this.mockExamId);

  final String mockExamId;
}

class MockExamAlreadyActive extends MockExamSubmitResult {
  const MockExamAlreadyActive(this.active);

  /// Null only if the active exam vanished between the two calls.
  final ActiveMockExam? active;
}

class MockExamSubmitFailed extends MockExamSubmitResult {
  const MockExamSubmitFailed(this.failure);

  final MockExamFailure failure;
}

class MockExamSetupCubit extends Cubit<MockExamSetupState> {
  MockExamSetupCubit(this._repository) : super(const MockExamSetupState()) {
    load();
  }

  final MockExamRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: MockExamSetupStatus.loading));
    final result = await _repository.getAvailability();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        _applyAvailability(data);
      case Error():
        emit(state.copyWith(status: MockExamSetupStatus.loadError));
    }
  }

  /// Only subjects the app knows how to draw (icon/color/label), minus
  /// Atualidades, and only if they have at least one question at all.
  static List<String> _offeredSubjects(MockExamAvailability availability) => [
    for (final subject in Subject.values)
      if (subject != Subject.atualidades &&
          availability.countFor(subject.name, MockExamDifficulty.misto) > 0)
        subject.name,
  ];

  /// Installs fresh availability and pulls every existing selection back
  /// inside it: a level that now has 0 falls back to Misto, a count above
  /// the new maximum is lowered to it, and a subject with nothing left is
  /// dropped. Counts only ever go down here, so the 180 cap still holds.
  void _applyAvailability(MockExamAvailability availability) {
    final subjects = _offeredSubjects(availability);
    final selections = <String, MockExamSubjectConfig>{};
    for (final entry in state.selections.values) {
      if (!subjects.contains(entry.subject)) continue;
      var difficulty = entry.difficulty;
      if (availability.countFor(entry.subject, difficulty) == 0) {
        difficulty = MockExamDifficulty.misto;
      }
      final count = min(
        entry.questionCount,
        availability.countFor(entry.subject, difficulty),
      );
      if (count <= 0) continue;
      selections[entry.subject] = entry.copyWith(
        difficulty: difficulty,
        questionCount: count,
      );
    }
    emit(
      state.copyWith(
        status: MockExamSetupStatus.ready,
        availability: availability,
        subjects: subjects,
        selections: selections,
      ),
    );
  }

  /// Selecting starts at Misto with the first valid count; deselecting
  /// drops the subject's whole config, so re-selecting starts fresh.
  void toggleSubject(String subject) {
    if (state.status != MockExamSetupStatus.ready || state.isSubmitting) {
      return;
    }
    final selections = {...state.selections};
    if (selections.remove(subject) == null) {
      final count = state.initialCount(subject, MockExamDifficulty.misto);
      if (count <= 0) return;
      selections[subject] = MockExamSubjectConfig(
        subject: subject,
        difficulty: MockExamDifficulty.misto,
        questionCount: count,
      );
    }
    emit(state.copyWith(selections: selections));
  }

  /// Switching level keeps the count if it still fits, otherwise lowers it
  /// to the new maximum -- never leaves a count above what that level has.
  void setDifficulty(String subject, MockExamDifficulty difficulty) {
    final entry = state.selections[subject];
    if (entry == null || state.isSubmitting) return;
    final ceiling = MockExamQuantity.ceiling(
      available: state.available(subject, difficulty),
      otherSubjectsTotal: state.otherSubjectsTotal(subject),
    );
    if (ceiling <= 0) return;
    emit(
      state.copyWith(
        selections: {
          ...state.selections,
          subject: entry.copyWith(
            difficulty: difficulty,
            questionCount: min(entry.questionCount, ceiling),
          ),
        },
      ),
    );
  }

  void increase(String subject) {
    final entry = state.selections[subject];
    if (entry == null || state.isSubmitting) return;
    _setCount(
      entry,
      MockExamQuantity.increase(
        current: entry.questionCount,
        available: state.available(subject, entry.difficulty),
        otherSubjectsTotal: state.otherSubjectsTotal(subject),
      ),
    );
  }

  void decrease(String subject) {
    final entry = state.selections[subject];
    if (entry == null || state.isSubmitting) return;
    final next = MockExamQuantity.decrease(entry.questionCount);
    if (next <= 0) return;
    _setCount(entry, next);
  }

  void _setCount(MockExamSubjectConfig entry, int count) {
    if (count == entry.questionCount) return;
    emit(
      state.copyWith(
        selections: {
          ...state.selections,
          entry.subject: entry.copyWith(questionCount: count),
        },
      ),
    );
  }

  Future<MockExamSubmitResult> submit() async {
    if (!state.canStart) {
      return MockExamSubmitFailed(
        MockExamFailure(MockExamFailureKind.invalidConfig),
      );
    }
    emit(state.copyWith(isSubmitting: true));
    final result = await _repository.createMockExam(state.orderedSelections);
    if (isClosed) {
      return MockExamSubmitFailed(
        MockExamFailure(MockExamFailureKind.unexpected),
      );
    }

    switch (result) {
      case Success(:final data):
        emit(state.copyWith(isSubmitting: false));
        return MockExamCreated(data);
      case Error(:final failure):
        final mockFailure = failure is MockExamFailure
            ? failure
            : MockExamFailure(MockExamFailureKind.unexpected);
        if (mockFailure.kind == MockExamFailureKind.alreadyActive) {
          final active = await _repository.getActiveMockExam();
          if (!isClosed) emit(state.copyWith(isSubmitting: false));
          return MockExamAlreadyActive(switch (active) {
            Success(:final data) => data,
            Error() => null,
          });
        }
        if (mockFailure.kind == MockExamFailureKind.insufficientQuestions) {
          // The screen was showing stale numbers: reload them (which also
          // pulls the selection back within the new limits) so the user
          // sees what's really there before trying again.
          final refreshed = await _repository.getAvailability();
          if (refreshed case Success(:final data) when !isClosed) {
            _applyAvailability(data);
          }
        }
        if (!isClosed) emit(state.copyWith(isSubmitting: false));
        return MockExamSubmitFailed(mockFailure);
    }
  }

  /// Discards the in-progress exam so a new one can be created. Returns
  /// null on success, or what went wrong. Never called without the user
  /// explicitly choosing "Descartar e montar outro".
  Future<MockExamFailure?> discardActive(String mockExamId) async {
    final result = await _repository.abandonMockExam(mockExamId);
    return switch (result) {
      Success() => null,
      Error(:final failure) =>
        failure is MockExamFailure
            ? failure
            : MockExamFailure(MockExamFailureKind.unexpected),
    };
  }
}
