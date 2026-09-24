import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/error_review/l10n/error_review_strings.dart';
import 'package:aura/features/error_review/presentation/cubit/error_review_cubit.dart';
import 'package:aura/features/error_review/presentation/cubit/error_review_state.dart';
import 'package:aura/features/error_review/presentation/pages/review_practice_page.dart';
import 'package:aura/features/error_review/presentation/widgets/error_topic_card.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class ErrorReviewListPage extends StatefulWidget {
  const ErrorReviewListPage({super.key});

  @override
  State<ErrorReviewListPage> createState() => _ErrorReviewListPageState();
}

class _ErrorReviewListPageState extends State<ErrorReviewListPage>
    with RouteAware {
  late final _cubit = ErrorReviewCubit(sl<ErrorReviewRepository>());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didPopNext() => _cubit.refresh();

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = ErrorReviewStrings(language);
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(title: t.pageTitle, showBackButton: true),
            Expanded(
              child: BlocBuilder<ErrorReviewCubit, ErrorReviewState>(
                builder: (context, state) => switch (state) {
                  ErrorReviewLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  ErrorReviewError(:final message) => _ErrorView(
                    strings: t,
                    message: message,
                  ),
                  ErrorReviewLoaded(topics: final topics) when topics.isEmpty =>
                    _EmptyView(strings: t),
                  ErrorReviewLoaded(:final topics) => ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: topics.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return ErrorTopicCard(
                        topic: topic,
                        language: language,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ReviewPracticePage(
                              catalogNodeId: topic.catalogNodeId,
                              title: topic.title,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.strings});

  final ErrorReviewStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AurudoIllustration(pose: AurudoPose.celebrating),
            const SizedBox(height: 16),
            Text(
              strings.emptyTitle,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.emptyDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings, required this.message});

  final ErrorReviewStrings strings;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<ErrorReviewCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
