import 'package:equatable/equatable.dart';

class RegisterFormState extends Equatable {
  const RegisterFormState({
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.submitted = false,
    this.revision = 0,
  });

  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool submitted;
  final int revision;

  RegisterFormState copyWith({
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? submitted,
    int? revision,
  }) {
    return RegisterFormState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      submitted: submitted ?? this.submitted,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
    obscurePassword,
    obscureConfirmPassword,
    submitted,
    revision,
  ];
}
