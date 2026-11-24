import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/paywall/presentation/widgets/paywall_common.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Resolução inicial do acesso (sessão aberta, servidor ainda não respondeu):
/// uma tela de espera estável, para não piscar conteúdo nem paywall. O roteador
/// a troca sozinho quando o acesso é decidido.
class AccessResolvingPage extends StatefulWidget {
  const AccessResolvingPage({super.key});

  @override
  State<AccessResolvingPage> createState() => _AccessResolvingPageState();
}

class _AccessResolvingPageState extends State<AccessResolvingPage> {
  @override
  void initState() {
    super.initState();
    // Idempotente (uma consulta por vez): garante a resolução mesmo se o
    // evento de sessão chegou antes de o app ouvir.
    unawaited(sl<AccessCubit>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Semantics(
          label: t('Verificando seu acesso', 'Checking your access', 'Verificando tu acceso'),
          child: const AppAuraLoader.large(),
        ),
      ),
    );
  }
}

/// A autorização offline venceu (ou o relógio foi alterado): é preciso
/// conectar para o servidor confirmar. NÃO diz que a assinatura venceu.
class ConnectionRequiredPage extends StatelessWidget {
  const ConnectionRequiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final loading = context.watch<AccessCubit>().state.loading;
    return PaywallFrame(
      pose: AurudoPose.thinking,
      children: [
        PaywallHeading(
          title: t('Conecte-se para verificar seu acesso', 'Connect to check your access',
              'Conéctate para verificar tu acceso'),
          body: t(
            'A autorização para estudar sem internet precisou ser renovada. Isso não significa que sua assinatura venceu: assim que você estiver online, confirmamos tudo e você continua de onde parou. Seu progresso está guardado.',
            'The authorization to study offline needs to be renewed. This does not mean your subscription has ended: as soon as you are online we confirm everything and you continue where you left off. Your progress is safe.',
            'La autorización para estudiar sin internet necesita renovarse. Esto no significa que tu suscripción haya vencido: en cuanto estés en línea lo confirmamos y sigues donde lo dejaste. Tu progreso está guardado.',
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: t('Tentar novamente', 'Try again', 'Intentar de nuevo'),
          isLoading: loading,
          onPressed: () => unawaited(sl<AccessCubit>().refresh(force: true)),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AccountFooter(showDelete: false),
      ],
    );
  }
}

/// Versão abaixo do mínimo configurado. A tela só orienta; a proteção real é
/// o gate do servidor (versões antigas já publicadas não têm esta tela).
class UpdateRequiredPage extends StatelessWidget {
  const UpdateRequiredPage({super.key});

  static String get _storeUrl {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'https://apps.apple.com/br/app/aprovaura/id6817047910';
    }
    return 'https://play.google.com/store/apps/details?id=com.lucasdiogof.aprovaura';
  }

  Future<void> _update() async {
    if (kIsWeb) {
      // Recarrega ignorando o cache dos assets antigos.
      final u = Uri.base.replace(queryParameters: {'v': '${DateTime.now().millisecondsSinceEpoch}'});
      await launchUrl(u, webOnlyWindowName: '_self');
      return;
    }
    await launchUrl(Uri.parse(_storeUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return PaywallFrame(
      pose: AurudoPose.neutral,
      children: [
        PaywallHeading(
          title: t('Atualize o AprovaAura', 'Update AprovaAura', 'Actualiza AprovaAura'),
          body: kIsWeb
              ? t('Há uma versão mais recente. Recarregue para continuar estudando. Seu progresso e sua conta continuam iguais.',
                  'A newer version is available. Reload to keep studying. Your progress and account stay the same.',
                  'Hay una versión más reciente. Recarga para seguir estudiando. Tu progreso y tu cuenta siguen igual.')
              : t('Uma versão mais recente é necessária para continuar. Atualize pela loja: seu progresso e sua conta continuam iguais.',
                  'A newer version is required to continue. Update from the store: your progress and account stay the same.',
                  'Se necesita una versión más reciente para continuar. Actualiza desde la tienda: tu progreso y tu cuenta siguen igual.'),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: kIsWeb
              ? t('Recarregar', 'Reload', 'Recargar')
              : t('Atualizar na loja', 'Update in the store', 'Actualizar en la tienda'),
          onPressed: () => unawaited(_update()),
        ),
        const SizedBox(height: AppSpacing.lg),
        const AccountFooter(showDelete: false),
      ],
    );
  }
}
