import 'package:aura/core/error/result.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/domain/repositories/access_repository.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/entities/pending_signup.dart';
import 'package:aura/features/auth/domain/entities/public_app_config.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';
import 'package:aura/features/partners/domain/repositories/partners_repository.dart';

/// Repositório de autenticação "sem nada pendente": cadastro livre, sem
/// confirmação interrompida e com o modelo comercial desligado. Os testes que
/// precisam de outro comportamento sobrescrevem o método (ou usam mocktail).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.config = const PublicAppConfig(), this.pending});

  PublicAppConfig? config;
  PendingSignup? pending;

  @override
  Future<PublicAppConfig?> publicConfig() async => config;

  @override
  Future<PendingSignup?> pendingSignup() async => pending;

  @override
  Future<void> clearPendingSignup() async => pending = null;

  @override
  AppUser? get currentUser => null;

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakeAuthRepository.${invocation.memberName}');
}

/// Acesso aberto (modelo comercial desligado, como em produção hoje).
class FakeAccessRepository implements AccessRepository {
  FakeAccessRepository([this.status = AccessStatus.open]);
  AccessStatus status;

  @override
  Future<Result<AccessStatus>> refresh() async => Success(status);

  @override
  Future<AccessContext> loadContext() async => const AccessContext();

  @override
  Future<void> clear() async {}
}

AccessCubit fakeAccessCubit([AccessStatus status = AccessStatus.open]) =>
    AccessCubit(FakeAccessRepository(status));

/// Professores: nenhum ativo e nenhum vínculo (Perfil abre sem rede).
class FakePartnersRepository implements PartnersRepository {
  @override
  Future<Result<List<PartnerSummary>>> listActive() async => const Success([]);

  @override
  Future<Result<List<PartnerSummary>>> search({String? query, int offset = 0, int limit = 30}) async =>
      const Success([]);

  @override
  Future<Result<PartnerLink>> getMyLink() async => const Success(PartnerLink());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('FakePartnersRepository.${invocation.memberName}');
}
