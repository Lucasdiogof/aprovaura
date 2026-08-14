import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/atualidades/presentation/pages/atualidades_areas_page.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/catalog/presentation/pages/catalog_list_page.dart';
import 'package:aura/features/home/presentation/widgets/streak_card.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

  String _displayName(String name, String email) {
    if (name.isNotEmpty) return name.split(' ').first;
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return localPart;
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = HomeStrings(language);
    final profileState = context.watch<ProfileCubit>().state;
    final displayName = _displayName(
      profileState.profile?.name ?? '',
      profileState.authUser.email,
    );
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
                      t.greeting(displayName),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.homeSubtitle,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    StreakCard(strings: t, streakDays: 0),
                    const SizedBox(height: 24),
                    Text(
                      t.chooseSubjectHeading,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                  (context, index) => SubjectCard(
                    subject: Subject.values[index],
                    language: language,
                    onTap: () =>
                        _openSubject(context, Subject.values[index], language),
                  ),
                  childCount: Subject.values.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
