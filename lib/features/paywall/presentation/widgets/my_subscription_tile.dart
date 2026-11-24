import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/paywall/presentation/widgets/paywall_common.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/profile/presentation/widgets/settings_tile.dart';

/// Linha "Minha assinatura" do Perfil. Só aparece com o modelo comercial
/// ligado no servidor: antes disso não há assinatura a mostrar.
class MySubscriptionTile extends StatelessWidget {
  const MySubscriptionTile({super.key});

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final s = context.watch<AccessCubit>().state.status;
    if (!s.enforced) return const SizedBox.shrink();
    final until = s.accessUntil;
    final subtitle = s.isAdmin
        ? t('Benefício administrativo', 'Administrative benefit', 'Beneficio administrativo')
        : s.isPartner
        ? t('Vinculado à parceria ativa', 'Tied to the active partnership', 'Vinculado a la alianza activa')
        : s.trialOnly && until != null
        ? t('Experiência Premium · restam ${remainingLabel(t, until.difference(DateTime.now()))}',
            'Premium experience · ${remainingLabel(t, until.difference(DateTime.now()))} left',
            'Experiencia Premium · quedan ${remainingLabel(t, until.difference(DateTime.now()))}')
        : s.allowed
        ? t('Premium ativo', 'Premium active', 'Premium activo')
        : t('Sem Premium ativo', 'No active Premium', 'Sin Premium activo');
    return SettingsTile(
      icon: Icons.workspace_premium_outlined,
      title: t('Minha assinatura', 'My subscription', 'Mi suscripción'),
      subtitle: subtitle,
      onTap: () => context.push('/minha-assinatura'),
    );
  }
}
