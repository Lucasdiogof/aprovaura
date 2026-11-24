import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';
import 'package:aura/features/partners/domain/repositories/partners_repository.dart';

class PartnerPickerState extends Equatable {
  const PartnerPickerState({
    this.items = const [],
    this.query = '',
    this.loading = true,
    this.failed = false,
    this.hasMore = false,
    this.anyPartner,
    this.selected,
  });

  final List<PartnerSummary> items;
  final String query;
  final bool loading;
  final bool failed;
  final bool hasMore;

  /// null = still unknown; false = no active teacher exists (picker hidden).
  final bool? anyPartner;
  final PartnerSummary? selected;

  PartnerPickerState copyWith({
    List<PartnerSummary>? items,
    String? query,
    bool? loading,
    bool? failed,
    bool? hasMore,
    bool? anyPartner,
    PartnerSummary? selected,
    bool clearSelected = false,
  }) => PartnerPickerState(
    items: items ?? this.items,
    query: query ?? this.query,
    loading: loading ?? this.loading,
    failed: failed ?? this.failed,
    hasMore: hasMore ?? this.hasMore,
    anyPartner: anyPartner ?? this.anyPartner,
    selected: clearSelected ? null : (selected ?? this.selected),
  );

  @override
  List<Object?> get props => [
    items,
    query,
    loading,
    failed,
    hasMore,
    anyPartner,
    selected,
  ];
}

/// Searchable, paginated list of active teachers (sign-up and profile).
class PartnerPickerCubit extends Cubit<PartnerPickerState> {
  PartnerPickerCubit(this._repository) : super(const PartnerPickerState());

  static const _page = 30;
  final PartnersRepository _repository;
  Timer? _debounce;
  int _seq = 0;

  Future<void> load() => _fetch('', append: false, probe: true);

  void search(String query) {
    _debounce?.cancel();
    emit(state.copyWith(query: query, loading: true, failed: false));
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _fetch(query.trim(), append: false),
    );
  }

  Future<void> more() {
    if (state.loading || !state.hasMore) return Future.value();
    return _fetch(state.query.trim(), append: true);
  }

  void select(PartnerSummary? partner) => emit(
    partner == null
        ? state.copyWith(clearSelected: true)
        : state.copyWith(selected: partner),
  );

  Future<void> _fetch(
    String query, {
    required bool append,
    bool probe = false,
  }) async {
    final seq = ++_seq;
    emit(state.copyWith(loading: true, failed: false));
    final result = await _repository.search(
      query: query.isEmpty ? null : query,
      offset: append ? state.items.length : 0,
      limit: _page,
    );
    if (isClosed || seq != _seq) return;
    switch (result) {
      case Success(:final data):
        emit(
          state.copyWith(
            items: append ? [...state.items, ...data] : data,
            loading: false,
            hasMore: data.length == _page,
            anyPartner: probe ? data.isNotEmpty : state.anyPartner,
          ),
        );
      case Error():
        emit(state.copyWith(loading: false, failed: true));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
