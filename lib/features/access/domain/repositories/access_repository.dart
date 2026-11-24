import 'package:aura/core/error/result.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';

abstract class AccessRepository {
  /// Pergunta ao servidor (get_my_access). Sem conexão, usa a autorização
  /// offline assinada da conta atual, se ainda válida. O servidor também
  /// concede o teste de 72h aqui, na primeira chamada elegível.
  Future<Result<AccessStatus>> refresh();

  /// Motivo do bloqueio (só texto do paywall). Sem conexão: contexto vazio.
  Future<AccessContext> loadContext();

  /// Apaga a autorização e dicas locais (saída da conta / exclusão).
  Future<void> clear();
}
