import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_state.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(
    this._repository,
    this._progressRepository, {
    required this.subject,
    this.parentId,
    this.difficulty,
  }) : super(const CatalogLoading()) {
    load();
  }

  final CatalogRepository _repository;
  final ProgressRepository _progressRepository;
  final String subject;
  final String? parentId;
  QuestionDifficulty? difficulty;

  Future<void> setDifficulty(QuestionDifficulty? value) async {
    if (difficulty == value) return;
    difficulty = value;
    await load();
  }

  Future<void> load() async {
    emit(const CatalogLoading());
    await _fetch();
  }

  // Reloads in place, without the CatalogLoading flash — used when returning
  // to this screen from a finished activity, so the progress bars update
  // without the list disappearing for a moment.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final result = await _repository.getChildren(
      subject: subject,
      parentId: parentId,
      difficulty: difficulty,
    );
    switch (result) {
      case Success(:final data):
        final progressResult = await _progressRepository.getBatchProgress(
          data.map((node) => node.id).toList(growable: false),
        );
        final progress = switch (progressResult) {
          Success(data: final progressMap) => progressMap,
          Error() => const <String, TopicProgress>{},
        };
        emit(CatalogLoaded(data, progress));
      case Error(:final failure):
        emit(CatalogError(failure.message));
    }
  }
}
