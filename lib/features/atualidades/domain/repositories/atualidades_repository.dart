import 'package:aura/core/error/result.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';

abstract class AtualidadesRepository {
  Future<Result<List<Dossier>>> getDossiers({required DossierArea area});
}
