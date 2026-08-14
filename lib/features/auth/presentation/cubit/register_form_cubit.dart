import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/auth/presentation/cubit/register_form_state.dart';

class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit() : super(const RegisterFormState());

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleObscureConfirmPassword() => emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  void markSubmitted() => emit(state.copyWith(submitted: true));

  void notifyFieldChanged() =>
      emit(state.copyWith(revision: state.revision + 1));
}
