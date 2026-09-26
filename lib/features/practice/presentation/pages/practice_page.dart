import 'package:flutter/foundation.dart';
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
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_card.dart';

/// The catalog, one card per subject. Practising a specific subject means
/// starting here; the shortcuts that pick questions across subjects live on
/// Home.
class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  // The "matérias em foco" seen on the previous build, so a subject that
  // just switched from out-of-focus to in-focus (the person just picked it
  // on the settings screen and came back) can play its sparkle once. Null
  // until the first real profile is seen, so opening the tab with an
  // already-focused subject never animates.
  Set<Subject>? _previousFocus;
  Set<Subject> _justEntered = const {};

  void _syncFocus(Set<Subject> current) {
    final previous = _previousFocus;
    // Idempotent on purpose: a rebuild for an unrelated reason (locale,
    // theme, anything else this page watches) must not recompute the diff
    // against a focus set that hasn't actually changed -- that would wipe
    // "just entered" before the sparkle has had a chance to show at all.
    if (previous != null && setEquals(previous, current)) return;
    _justEntered = previous == null ? const {} : current.difference(previous);
    _previousFocus = current;
  }

  /// Focused subjects first, in the order they were favorited (the order
  /// `interestedSubjects` was saved in), then everything else in
  /// `Subject.values` order. Picking a subject as "em foco" is now a real
  /// reason to see it without scrolling, not just a border, and the person's
  /// own choice of which came first is what decides the order -- not an
  /// arbitrary fixed one. Redação isn't part of this: it always closes the
  /// grid, focus or not.
  List<Subject> _orderedSubjects(List<Subject> focusOrder) {
    final ordered = <Subject>[];
    final seen = <Subject>{};
    for (final subject in focusOrder) {
      if (seen.add(subject)) ordered.add(subject);
    }
    for (final subject in Subject.values) {
      if (seen.add(subject)) ordered.add(subject);
    }
    return ordered;
  }

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
    final focusOrder = context
        .watch<ProfileCubit>()
        .state
        .profile
        ?.interestedSubjects;
    final focus = focusOrder?.toSet();
    if (focus != null) _syncFocus(focus);
    final orderedSubjects = _orderedSubjects(focusOrder ?? const []);
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
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  // Redação closes the grid: same tile, but it is a feature
                  // of its own rather than a Subject (see EssaySubjectCard).
                  // It has no "em foco" state -- it isn't a Subject, so it
                  // never appears in the interested-subjects screen, and it
                  // never moves even when focused subjects reorder above it.
                  (context, index) {
                    if (index == orderedSubjects.length) {
                      return EssaySubjectCard(
                        language: language,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const EssayThemesPage(),
                          ),
                        ),
                      );
                    }
                    final subject = orderedSubjects[index];
                    return SubjectCard(
                      key: ValueKey(subject),
                      subject: subject,
                      language: language,
                      inFocus: focus?.contains(subject) ?? false,
                      justEnteredFocus: _justEntered.contains(subject),
                      onTap: () => _openSubject(context, subject, language),
                    );
                  },
                  childCount: orderedSubjects.length + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
