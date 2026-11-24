import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';
import 'package:aura/features/partners/domain/repositories/partners_repository.dart';

class PartnerLinkState extends Equatable {
  const PartnerLinkState({this.link, this.busy = false, this.failed = false});

  final PartnerLink? link;
  final bool busy;
  final bool failed;

  @override
  List<Object?> get props => [link, busy, failed];
}

/// The student's own teacher link in the profile: first self-link, then
/// change requests (the server enforces one link and one pending request).
class PartnerLinkCubit extends Cubit<PartnerLinkState> {
  PartnerLinkCubit(this._repository) : super(const PartnerLinkState());

  final PartnersRepository _repository;

  Future<void> load() async {
    final result = await _repository.getMyLink();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(PartnerLinkState(link: data));
      case Error():
        emit(PartnerLinkState(link: state.link, failed: true));
    }
  }

  /// First choice, made by the student. Returns true on success.
  Future<bool> linkTo(String partnerId) =>
      _run(() => _repository.link(partnerId: partnerId));

  Future<bool> requestChange(String partnerId, String? reason) => _run(
    () => _repository.requestChange(partnerId: partnerId, reason: reason),
  );

  Future<bool> _run(Future<Result<void>> Function() action) async {
    emit(PartnerLinkState(link: state.link, busy: true));
    final result = await action();
    if (isClosed) return false;
    await load();
    return result is Success;
  }
}
