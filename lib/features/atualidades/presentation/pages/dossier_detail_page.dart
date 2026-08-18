import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/atualidades/domain/entities/dossier.dart';
import 'package:aura/features/atualidades/l10n/atualidades_strings.dart';
import 'package:aura/features/atualidades/presentation/pages/dossier_practice_page.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class DossierDetailPage extends StatelessWidget {
  const DossierDetailPage({required this.dossier, super.key});

  final Dossier dossier;

  @override
  Widget build(BuildContext context) {
    final t = AtualidadesStrings(context.watch<LocaleCubit>().state);
    final sections = <String, String?>{
      t.contextLabel: dossier.context,
      t.whatHappenedLabel: dossier.whatHappened,
      t.whyItHappenedLabel: dossier.whyItHappened,
      t.whoIsInvolvedLabel: dossier.whoIsInvolved,
      t.consequencesLabel: dossier.consequences,
      t.keyTakeawaysLabel: dossier.keyTakeaways,
    };
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(
            title: dossier.title,
            subtitle: dossier.readMinutes != null
                ? t.readMinutesLabel(dossier.readMinutes!)
                : null,
            showBackButton: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (dossier.summary != null) ...[
                  Text(
                    dossier.summary!,
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                ],
                for (final entry in sections.entries)
                  if (entry.value != null) ...[
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value!,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                  ],
                if (dossier.sources.isNotEmpty) ...[
                  Text(
                    t.sourcesLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  for (final source in dossier.sources)
                    Text(
                      '• $source',
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  const SizedBox(height: 20),
                ],
                AppButton(
                  label: t.practiceButtonLabel,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DossierPracticePage(dossier: dossier),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
