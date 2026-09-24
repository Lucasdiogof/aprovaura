import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/l10n/atualidades_strings.dart';

/// A small "Novo" / "Atualizado hoje" / "Atualizado há N dias" badge label,
/// built only from published_at/updated_at -- both real, DB-populated
/// timestamps (see dossiers_schema.sql), never a made-up date. Returns
/// null (no badge) whenever there's nothing honest to say: dates missing,
/// or a dossiê that's neither recently published nor edited since.
///
/// [now] exists only so tests don't depend on the real clock.
String? dossierFreshnessLabel(
  Dossier dossier,
  AtualidadesStrings strings, {
  DateTime? now,
}) {
  final published = dossier.publishedAt;
  final updated = dossier.updatedAt;
  if (published == null || updated == null) return null;
  final today = now ?? DateTime.now();

  // The updated_at trigger also fires on the initial insert, so a fresh
  // row's updated_at sits a few milliseconds after published_at -- this
  // margin is what tells "actually edited later" apart from "just
  // published".
  final wasEditedAfterPublish =
      updated.difference(published) > const Duration(minutes: 5);
  if (wasEditedAfterPublish) {
    final daysSinceUpdate = today.difference(updated).inDays;
    return daysSinceUpdate <= 0
        ? strings.updatedTodayBadge
        : strings.updatedDaysAgoBadge(daysSinceUpdate);
  }

  final daysSincePublish = today.difference(published).inDays;
  return daysSincePublish <= 2 ? strings.newBadge : null;
}
