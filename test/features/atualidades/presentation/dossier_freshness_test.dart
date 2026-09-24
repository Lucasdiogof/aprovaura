import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/l10n/atualidades_strings.dart';
import 'package:aura/features/atualidades/presentation/dossier_freshness.dart';

void main() {
  const strings = AtualidadesStrings(AppLanguage.portuguese);
  final now = DateTime(2026, 9, 24, 12);

  group(dossierFreshnessLabel, () {
    test('returns null when either date is missing', () {
      const dossier = Dossier(id: 'd1', title: 'T');
      expect(dossierFreshnessLabel(dossier, strings, now: now), isNull);
    });

    test('a dossier published today (never edited since) is "Novo"', () {
      final dossier = Dossier(
        id: 'd1',
        title: 'T',
        publishedAt: now,
        updatedAt: now,
      );
      expect(dossierFreshnessLabel(dossier, strings, now: now), 'Novo');
    });

    test('published 2 days ago (never edited since) is still "Novo"', () {
      final publishedAt = now.subtract(const Duration(days: 2));
      final dossier = Dossier(
        id: 'd1',
        title: 'T',
        publishedAt: publishedAt,
        updatedAt: publishedAt,
      );
      expect(dossierFreshnessLabel(dossier, strings, now: now), 'Novo');
    });

    test('published 10 days ago (never edited since) has no badge', () {
      final publishedAt = now.subtract(const Duration(days: 10));
      final dossier = Dossier(
        id: 'd1',
        title: 'T',
        publishedAt: publishedAt,
        updatedAt: publishedAt,
      );
      expect(dossierFreshnessLabel(dossier, strings, now: now), isNull);
    });

    test('edited today, long after publishing, is "Atualizado hoje"', () {
      final dossier = Dossier(
        id: 'd1',
        title: 'T',
        publishedAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      );
      expect(
        dossierFreshnessLabel(dossier, strings, now: now),
        'Atualizado hoje',
      );
    });

    test('edited 2 days ago, long after publishing, shows the day count', () {
      final dossier = Dossier(
        id: 'd1',
        title: 'T',
        publishedAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 2)),
      );
      expect(
        dossierFreshnessLabel(dossier, strings, now: now),
        'Atualizado há 2 dias',
      );
    });
  });
}
