import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/paywall/presentation/widgets/paywall_common.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/shared/utils/external_link.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Novo aceite obrigatório (só aparece quando o servidor confirma que uma versão
/// publicada exige reaceite). Mantém sempre acessíveis: ler os documentos, sair,
/// trocar de conta e excluir a conta (rodapé). O roteador troca a tela sozinho
/// assim que o aceite é registrado.
class LegalAcceptancePage extends StatefulWidget {
  const LegalAcceptancePage({super.key});

  @override
  State<LegalAcceptancePage> createState() => _LegalAcceptancePageState();
}

class _LegalAcceptancePageState extends State<LegalAcceptancePage> {
  bool _busy = false, _failed = false;

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    final ok = await sl<AccessCubit>().acceptLegal();
    if (mounted) {
      setState(() {
        _busy = false;
        _failed = !ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final docs = context.watch<AccessCubit>().state.legalPending;
    final names = {
      'terms': t('Termos de uso', 'Terms of use', 'Términos de uso'),
      'privacy': t('Política de privacidade', 'Privacy policy', 'Política de privacidad'),
    };
    return PaywallFrame(
      pose: AurudoPose.thinking,
      children: [
        PaywallHeading(
          title: t('Atualizamos nossos documentos', 'We updated our documents', 'Actualizamos nuestros documentos'),
          body: t(
            'Leia as novas versões e confirme para continuar. Seu progresso está guardado e você pode sair ou excluir sua conta a qualquer momento.',
            'Read the new versions and confirm to continue. Your progress is safe and you can sign out or delete your account at any time.',
            'Lee las nuevas versiones y confirma para continuar. Tu progreso está guardado y puedes salir o eliminar tu cuenta en cualquier momento.',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final d in docs)
          if (d.url != null)
            TextButton(
              onPressed: () => openExternalLink(context, d.url!),
              child: Text('${names[d.kind] ?? d.kind} · ${d.version}'),
            )
          else
            Text('${names[d.kind] ?? d.kind} · ${d.version}', textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: t('Li e aceito', 'I have read and accept', 'He leído y acepto'),
          isLoading: _busy,
          onPressed: _busy ? null : _accept,
        ),
        if (_failed) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            t('Não foi possível registrar agora. Verifique a conexão e tente de novo.',
                'Could not save right now. Check your connection and try again.',
                'No se pudo registrar ahora. Revisa la conexión e inténtalo de nuevo.'),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        const AccountFooter(),
      ],
    );
  }
}
