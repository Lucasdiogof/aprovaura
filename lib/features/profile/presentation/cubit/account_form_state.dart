import 'package:equatable/equatable.dart';

class AccountFormState extends Equatable {
  const AccountFormState({this.revision = 0, this.saving = false});

  final int revision;
  final bool saving;

  AccountFormState copyWith({int? revision, bool? saving}) {
    return AccountFormState(
      revision: revision ?? this.revision,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [revision, saving];
}
