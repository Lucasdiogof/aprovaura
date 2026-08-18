import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_state.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(
    this._repository, {
    required this.subject,
    this.parentId,
    this.difficulty,
  }) : super(const CatalogLoading()) {
    load();
  }

  final CatalogRepository _repository;
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
    final result = await _repository.getChildren(
      subject: subject,
      parentId: parentId,
      difficulty: difficulty,
    );
    switch (result) {
      case Success(:final data):
        emit(CatalogLoaded(data));
      case Error(:final failure):
        emit(CatalogError(failure.message));
    }
  }
}
