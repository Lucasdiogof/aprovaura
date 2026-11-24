import 'package:aura/core/error/result.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';

abstract class PartnersRepository {
  /// Só professores ativos (list_active_partners). Opção padrão do cadastro
  /// continua sendo "nenhuma indicação".
  Future<Result<List<PartnerSummary>>> listActive();

  Future<Result<PartnerLink>> getMyLink();

  /// Vínculo único feito pelo próprio aluno (link_partner).
  Future<Result<void>> link({String? partnerId, String? code});

  /// Troca posterior: depende de aprovação administrativa.
  Future<Result<void>> requestChange({
    required String partnerId,
    String? reason,
  });
}
