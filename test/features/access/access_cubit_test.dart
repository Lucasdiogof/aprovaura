import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/domain/repositories/access_repository.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';

class _Repo implements AccessRepository {
  _Repo(this.result);
  Result<AccessStatus> result;
  AccessContext context = const AccessContext();
  int refreshes = 0, contexts = 0, clears = 0;

  @override
  Future<Result<AccessStatus>> refresh() async {
    refreshes++;
    return result;
  }

  @override
  Future<AccessContext> loadContext() async {
    contexts++;
    return context;
  }

  List<PendingLegal>? legal = const [];
  bool acceptOk = true;
  int accepts = 0;

  @override
  Future<List<PendingLegal>?> loadPendingLegal() async => legal;

  @override
  Future<bool> acceptLegal(List<PendingLegal> docs, String platform) async {
    accepts++;
    if (acceptOk) legal = const [];
    return acceptOk;
  }

  @override
  Future<void> clear() async => clears++;
}

const _blocked = AccessStatus(enforced: true, allowed: false);
const _allowed = AccessStatus(enforced: true, allowed: true);

void main() {
  group('AccessCubit.gate', () {
    test('antes da primeira resposta: resolving (nunca pisca conteúdo nem paywall)', () {
      final c = AccessCubit(_Repo(const Success(_allowed)), version: '1.1.0');
      expect(c.gate, AccessGate.resolving);
    });

    test('modelo desligado (enforced=false): sempre aberto', () async {
      final c = AccessCubit(_Repo(const Success(AccessStatus.open)), version: '1.1.0');
      await c.refresh(force: true);
      expect(c.gate, AccessGate.open);
    });

    test('ligado e permitido: aberto; ligado e negado: paywall com o motivo', () async {
      final repo = _Repo(const Success(_allowed));
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      expect(c.gate, AccessGate.open);

      repo.result = const Success(_blocked);
      repo.context = const AccessContext(reason: BlockReason.trialExpired);
      await c.refresh(force: true);
      expect(c.gate, AccessGate.paywall);
      expect(c.state.context.reason, BlockReason.trialExpired);
      expect(repo.contexts, 1);
    });

    test('sem autorização offline válida: connectionRequired (e não busca motivo)', () async {
      final repo = _Repo(const Success(AccessStatus.connectionRequired));
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      expect(c.gate, AccessGate.connectionRequired);
      expect(repo.contexts, 0);
    });

    test('versão abaixo do mínimo: updateRequired só com o modelo ligado', () async {
      const minV = {'android': '9.0.0', 'ios': '9.0.0', 'web': '9.0.0'};
      final repo = _Repo(const Success(AccessStatus(enforced: true, allowed: true, minVersion: minV)));
      final c = AccessCubit(repo, version: '1.0.0');
      await c.refresh(force: true);
      expect(c.gate, AccessGate.updateRequired);

      repo.result = const Success(AccessStatus(enforced: false, allowed: true, minVersion: minV));
      await c.refresh(force: true);
      expect(c.gate, AccessGate.open);
    });

    test('erro que não é de conexão mantém o último estado (não inventa bloqueio)', () async {
      final repo = _Repo(const Success(_allowed));
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      repo.result = Error(ServerFailure());
      await c.refresh(force: true);
      expect(c.gate, AccessGate.open);
      expect(c.state.failure, isA<ServerFailure>());
    });

    test('reset limpa a conta anterior e volta a resolving', () async {
      final repo = _Repo(const Success(_blocked));
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      await c.reset();
      expect(repo.clears, 1);
      expect(c.gate, AccessGate.resolving);
    });

    test('refresh sem force respeita o intervalo mínimo; com force refaz', () async {
      final repo = _Repo(const Success(_allowed));
      var now = DateTime(2026, 12, 1, 10);
      final c = AccessCubit(repo, clock: () => now, version: '1.1.0');
      await c.refresh();
      await c.refresh();
      expect(repo.refreshes, 1);
      now = now.add(const Duration(seconds: 61));
      await c.refresh();
      expect(repo.refreshes, 2);
      await c.refresh(force: true);
      expect(repo.refreshes, 3);
    });
  });

  group('AccessCubit reaceite legal', () {
    const doc = PendingLegal(kind: 'terms', version: '2027-01-01');

    test('servidor exige reaceite: gate legalRequired, antes do paywall; aceitar libera', () async {
      final repo = _Repo(const Success(_blocked))..legal = [doc];
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      expect(c.gate, AccessGate.legalRequired);
      expect(await c.acceptLegal(), isTrue);
      expect(c.gate, AccessGate.paywall);
    });

    test('falha ao consultar (null) NUNCA bloqueia e mantém o que já se sabia', () async {
      final repo = _Repo(const Success(_allowed))..legal = null;
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      expect(c.gate, AccessGate.open);
      repo.legal = [doc];
      await c.refresh(force: true);
      repo.legal = null;
      await c.refresh(force: true);
      expect(c.gate, AccessGate.legalRequired);
    });

    test('aceite que falha mantém a tela de aceite', () async {
      final repo = _Repo(const Success(_allowed))..legal = [doc]..acceptOk = false;
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      expect(await c.acceptLegal(), isFalse);
      expect(c.gate, AccessGate.legalRequired);
    });

    test('exigir conexão tem precedência e não consulta documentos', () async {
      final repo = _Repo(const Success(AccessStatus.connectionRequired))..legal = [doc];
      final c = AccessCubit(repo, version: '1.1.0');
      await c.refresh(force: true);
      expect(c.gate, AccessGate.connectionRequired);
    });
  });
}
