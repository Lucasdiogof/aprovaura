import 'package:equatable/equatable.dart';

/// Professor parceiro ativo, como aparece na lista de indicação.
/// Chave (SharedPreferences) do código de indicação vindo de ?ref=.
const kReferralKey = 'pending_referral_code';

class PartnerSummary extends Equatable {
  const PartnerSummary({required this.id, required this.displayName});

  final String id;
  final String displayName;

  @override
  List<Object?> get props => [id, displayName];
}

/// Vínculo do aluno com um professor (get_my_partner).
class PartnerLink extends Equatable {
  const PartnerLink({
    this.partnerId,
    this.displayName,
    this.linkedAt,
    this.everChose = false,
    this.hasPendingChange = false,
  });

  final String? partnerId;
  final String? displayName;
  final DateTime? linkedAt;

  /// Já escolheu professor alguma vez: novas trocas exigem solicitação.
  final bool everChose;
  final bool hasPendingChange;

  bool get isLinked => partnerId != null;

  /// O aluno ainda tem o único vínculo livre (nunca escolheu).
  bool get canSelfLink => !everChose;

  @override
  List<Object?> get props => [
    partnerId,
    displayName,
    linkedAt,
    everChose,
    hasPendingChange,
  ];
}
