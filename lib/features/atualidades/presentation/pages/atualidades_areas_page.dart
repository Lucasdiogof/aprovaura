import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/atualidades/domain/entities/dossier_area.dart';
import 'package:aura/features/atualidades/l10n/atualidades_strings.dart';
import 'package:aura/features/atualidades/presentation/pages/dossier_list_page.dart';
import 'package:aura/features/profile/presentation/widgets/profile_row.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class AtualidadesAreasPage extends StatelessWidget {
  const AtualidadesAreasPage({super.key});

  void _openArea(BuildContext context, DossierArea area) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DossierListPage(area: area)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = AtualidadesStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(
            title: t.pageTitle,
            subtitle: t.areasPageSubtitle,
            showBackButton: true,
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: DossierArea.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final area = DossierArea.values[index];
                return ProfileRow(
                  icon: area.icon,
                  label: area.label(language),
                  value: area.description(language),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.colors.textSecondary,
                  ),
                  onTap: () => _openArea(context, area),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
