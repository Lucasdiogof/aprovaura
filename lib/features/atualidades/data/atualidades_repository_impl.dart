import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';

class AtualidadesRepositoryImpl implements AtualidadesRepository {
  AtualidadesRepositoryImpl(this._client, this._localeCubit);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;

  @override
  Future<Result<List<Dossier>>> getDossiers({required DossierArea area}) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'get_dossiers',
        params: {
          'p_area': area.name,
          'p_locale': _localeCubit.state.databaseLocale,
        },
      );
      return Success(
        rows
            .cast<Map<String, dynamic>>()
            .map(Dossier.fromJson)
            .toList(growable: false),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
