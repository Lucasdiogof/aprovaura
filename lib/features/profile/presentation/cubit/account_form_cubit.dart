import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/profile/presentation/cubit/account_form_state.dart';

class AccountFormCubit extends Cubit<AccountFormState> {
  AccountFormCubit() : super(const AccountFormState());

  void notifyFieldChanged() =>
      emit(state.copyWith(revision: state.revision + 1));

  void setSaving(bool saving) => emit(state.copyWith(saving: saving));
}
