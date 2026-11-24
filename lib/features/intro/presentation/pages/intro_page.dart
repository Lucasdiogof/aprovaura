import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/domain/entities/public_app_config.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/intro/data/intro_store.dart';
import 'package:aura/features/intro/l10n/intro_strings.dart';
import 'package:aura/features/intro/presentation/widgets/intro_visuals.dart';
import 'package:aura/shared/widgets/app_button.dart';

/// The animated product presentation, shown once per install to a signed-out
/// person (skippable). It only presents; sign-up / login / e-mail
/// confirmation / personal setup are separate steps that follow it.
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  static const _count = 5;
  final _controller = PageController();
  final _store = IntroStore(sl<SharedPreferences>());
  int _page = 0;
  PublicAppConfig? _config;

  bool get _last => _page == _count - 1;

  @override
  void initState() {
    super.initState();
    // Only used to word the trial line when the commercial model is active.
    unawaited(
      sl<AuthRepository>().publicConfig().then((config) {
        if (mounted) setState(() => _config = config);
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) {
    if (page < 0 || page >= _count) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
    } else {
      unawaited(
        _controller.animateToPage(
          page,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  void _next() => _go(_page + 1);

  void _previous() => _go(_page - 1);

  Future<void> _finish({required bool create}) async {
    await _store.markIntroSeen();
    if (!mounted) return;
    context.go('/login');
    if (create) unawaited(context.push('/cadastro'));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = IntroStrings(language);
    final colors = context.colors;
    final reduce = MediaQuery.disableAnimationsOf(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): _next,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _previous,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    _TopBar(
                      t: t,
                      language: language,
                      showBack: _page > 0,
                      showSkip: !_last,
                      onBack: _previous,
                      onSkip: () => _finish(create: false),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _count,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (context, i) => _Parallax(
                          controller: _controller,
                          index: i,
                          reduce: reduce,
                          child: _SlideLayout(
                            visual: _visual(i, t),
                            title: _title(i, t),
                            body: _body(i, t),
                            note: _note(i, t),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Dots(
                      count: _count,
                      page: _page,
                      reduce: reduce,
                      label: t.pageOf(_page + 1, _count),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppButton(
                              label: _last ? t.createAccount : t.next,
                              onPressed: _last
                                  ? () => _finish(create: true)
                                  : _next,
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () => _finish(create: false),
                              style: TextButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                              ),
                              child: Text(t.haveAccount),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _visual(int i, IntroStrings t) {
    final active = i == _page;
    return switch (i) {
      0 => IntroWelcomeVisual(active: active),
      1 => IntroPracticeVisual(active: active, strings: t),
      2 => IntroProgressVisual(active: active, strings: t),
      3 => IntroEssayVisual(active: active, strings: t),
      _ => IntroFarmVisual(active: active, strings: t),
    };
  }

  String _title(int i, IntroStrings t) =>
      [t.t1Title, t.t2Title, t.t3Title, t.t4Title, t.t5Title][i];

  String _body(int i, IntroStrings t) =>
      [t.t1Body, t.t2Body, t.t3Body, t.t4Body, t.t5Body][i];

  /// Small print under the body: the essay disclaimer, and (last page, only
  /// while the commercial model is active) the trial line. Never says the
  /// trial already started: it starts when the e-mail is confirmed.
  String? _note(int i, IntroStrings t) {
    if (i == 3) return t.t4Note;
    if (i == 4) {
      final c = _config;
      return c != null && c.enforced ? t.trialLine(c.trialDays) : t.t5Cta;
    }
    return null;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.t,
    required this.language,
    required this.showBack,
    required this.showSkip,
    required this.onBack,
    required this.onSkip,
  });

  final IntroStrings t;
  final AppLanguage language;
  final bool showBack;
  final bool showSkip;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Visibility(
              visible: showBack,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                tooltip: t.back,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            const Spacer(),
            PopupMenuButton<AppLanguage>(
              tooltip: t.languageTooltip,
              icon: const Icon(Icons.translate_rounded),
              onSelected: (l) => context.read<LocaleCubit>().setLanguage(l),
              itemBuilder: (_) => [
                for (final l in AppLanguage.values)
                  CheckedPopupMenuItem(
                    value: l,
                    checked: l == language,
                    child: Text(l.label),
                  ),
              ],
            ),
            Visibility(
              visible: showSkip,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(onPressed: onSkip, child: Text(t.skip)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slides a little against the page scroll and fades with distance, so the
/// change of page reads as depth instead of a flat swipe. Skipped under
/// reduced motion.
class _Parallax extends StatelessWidget {
  const _Parallax({
    required this.controller,
    required this.index,
    required this.reduce,
    required this.child,
  });

  final PageController controller;
  final int index;
  final bool reduce;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduce) return child;
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final page = controller.hasClients && controller.position.haveDimensions
            ? (controller.page ?? index.toDouble())
            : index.toDouble();
        final delta = page - index;
        final near = (1 - delta.abs()).clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.3 + 0.7 * near,
          child: Transform.translate(
            offset: Offset(-delta * 36, 0),
            child: child,
          ),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.page,
    required this.reduce,
    required this.label,
  });

  final int count;
  final int page;
  final bool reduce;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              AnimatedContainer(
                duration: reduce
                    ? Duration.zero
                    : const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == page ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: i == page ? colors.primary : colors.border,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One slide: on a phone the visual sits above the text; on a wide window
/// (tablet landscape / desktop) they sit side by side instead of stretching
/// the mobile layout.
class _SlideLayout extends StatelessWidget {
  const _SlideLayout({
    required this.visual,
    required this.title,
    required this.body,
    this.note,
  });

  final Widget visual;
  final String title;
  final String body;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 860;
        Widget text(CrossAxisAlignment align) {
          final textAlign = align == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: align,
            children: [
              Text(
                title,
                textAlign: textAlign,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  fontSize: wide ? 34 : null,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: textAlign,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.textSecondary,
                  height: 1.4,
                  fontSize: wide ? 18 : null,
                ),
              ),
              if (note != null) ...[
                const SizedBox(height: 12),
                Text(
                  note!,
                  textAlign: textAlign,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textHint,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          );
        }

        final scaled = FittedBox(fit: BoxFit.contain, child: visual);
        if (wide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Center(child: scaled)),
                const SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: text(CrossAxisAlignment.start),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(child: Center(child: scaled)),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: box.maxHeight * 0.42),
                child: SingleChildScrollView(
                  child: text(CrossAxisAlignment.center),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}
