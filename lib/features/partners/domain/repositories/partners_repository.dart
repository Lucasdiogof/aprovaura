import 'package:aura/core/error/result.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';

abstract class PartnersRepository {
  /// Só professores ativos (list_active_partners). Opção padrão do cadastro
  /// continua sendo "nenhuma indicação".
  Future<Result<List<PartnerSummary>>> listActive();

  /// Busca paginada (search_active_partners): ordem alfabética, só nome de
  /// divulgação. Funciona antes do login (cadastro).
  Future<Result<List<PartnerSummary>>> search({
    String? query,
    int offset = 0,
    int limit = 30,
  });

  Future<Result<PartnerLink>> getMyLink();

  /// Vínculo único feito pelo próprio aluno (link_partner).
  Future<Result<void>> link({String? partnerId, String? code});

  /// Troca posterior: depende de aprovação administrativa.
  Future<Result<void>> requestChange({
    required String partnerId,
    String? reason,
  });
}
