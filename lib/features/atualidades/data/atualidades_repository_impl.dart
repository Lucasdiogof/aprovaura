import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';

class AtualidadesRepositoryImpl implements AtualidadesRepository {
  AtualidadesRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Dossier>>> getDossiers({required DossierArea area}) async {
    try {
      final rows = await _client
          .from('dossiers')
          .select()
          .eq('area', area.name)
          .order('order_index');
      return Success(
        rows.map((row) => Dossier.fromJson(row)).toList(growable: false),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
