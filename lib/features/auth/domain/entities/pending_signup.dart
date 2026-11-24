import 'package:equatable/equatable.dart';

/// Cadastro criado cujo e-mail ainda não foi confirmado. Guardado no
/// aparelho (nunca a senha) para retomar a confirmação se o app fechar, e
/// para refazer o cadastro caso o e-mail precise ser corrigido.
class PendingSignup extends Equatable {
  const PendingSignup({
    required this.email,
    this.name,
    this.username,
    this.referralPartnerId,
    this.legalAccept = const {},
  });

  final String email;
  final String? name;
  final String? username;
  final String? referralPartnerId;
  final Map<String, String> legalAccept;

  @override
  List<Object?> get props => [
    email,
    name,
    username,
    referralPartnerId,
    legalAccept,
  ];
}
