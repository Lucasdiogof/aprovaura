import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/paywall/presentation/widgets/paywall_common.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/shared/widgets/aura/aura_glyph.dart';

/// Indicação discreta (só na Home) enquanto o acesso vem apenas do teste de
/// 72h. O prazo é o que o servidor autorizou: nada aqui estende ou reinicia o
/// teste. Some sozinho quando há assinatura, cortesia ou papel, e quando o
/// modelo comercial está desligado.
class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessCubit, AccessState>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) {
        final s = state.status;
        final until = s.accessUntil;
        if (!s.enforced || !s.allowed || !s.trialOnly || until == null) {
          return const SizedBox.shrink();
        }
        final remaining = until.difference(DateTime.now());
        if (remaining.isNegative) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: TrialSummaryCard(status: s),
        );
      },
    );
  }
}

/// Cartão do teste (Home e "Minha assinatura"): status, tempo restante, data de
/// expiração e atalho para conhecer os planos / assinar antes do fim.
class TrialSummaryCard extends StatelessWidget {
  const TrialSummaryCard({required this.status, super.key});
  final AccessStatus status;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final c = context.colors;
    final until = status.accessUntil!;
    final remaining = until.difference(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: c.auraViolet.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const AuraGlyph(size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('Experiência Premium · restam ${remainingLabel(t, remaining)}',
                      'Premium experience · ${remainingLabel(t, remaining)} left',
                      'Experiencia Premium · quedan ${remainingLabel(t, remaining)}'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
                ),
                Text(
                  t('Termina em ${t.dateTime(until)}', 'Ends on ${t.dateTime(until)}',
                      'Termina el ${t.dateTime(until)}'),
                  style: TextStyle(fontSize: 12, color: c.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/assinatura'),
            child: Text(t('Ver planos', 'See plans', 'Ver planes')),
          ),
        ],
      ),
    );
  }
}
