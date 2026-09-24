import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/atualidades/presentation/pages/atualidades_areas_page.dart';
import 'package:aura/features/catalog/presentation/pages/catalog_list_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_themes_page.dart';
import 'package:aura/features/essay/presentation/widgets/essay_subject_card.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/practice/l10n/practice_strings.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_card.dart';

/// The catalog, one card per subject. Practising a specific subject means
/// starting here; the shortcuts that pick questions across subjects live on
/// Home.
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  void _openSubject(
    BuildContext context,
    Subject subject,
    AppLanguage language,
  ) {
    if (subject == Subject.atualidades) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AtualidadesAreasPage()),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CatalogListPage(subject: subject, title: subject.label(language)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = PracticeStrings(language);
    final homeStrings = HomeStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.pageTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      homeStrings.chooseSubjectHeading,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                delegate: SliverChildBuilderDelegate(
                  // Redação closes the grid: same tile, but it is a feature
                  // of its own rather than a Subject (see EssaySubjectCard).
                  (context, index) => index == Subject.values.length
                      ? EssaySubjectCard(
                          language: language,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const EssayThemesPage(),
                            ),
                          ),
                        )
                      : SubjectCard(
                          subject: Subject.values[index],
                          language: language,
                          onTap: () => _openSubject(
                            context,
                            Subject.values[index],
                            language,
                          ),
                        ),
                  childCount: Subject.values.length + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
