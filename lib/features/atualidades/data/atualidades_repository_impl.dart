import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';

class AtualidadesRepositoryImpl implements AtualidadesRepository {
  AtualidadesRepositoryImpl(this._client, this._localeCubit, this._cache);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;
  final OfflineCache _cache;

  @override
  Future<Result<List<Dossier>>> getDossiers({required DossierArea area}) async {
    final locale = _localeCubit.state.databaseLocale;
    final result = await _cache.rowsWithFallback(
      _cache.publicKey('dossiers.$locale.${area.name}'),
      () => _client.rpc<List<dynamic>>(
        'get_dossiers',
        params: {'p_area': area.name, 'p_locale': locale},
      ),
    );
    return switch (result) {
      Success(:final data) => Success(
        data.map(Dossier.fromJson).toList(growable: false),
      ),
      Error(:final failure) => Error(failure),
    };
  }
}
