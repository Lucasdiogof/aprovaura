import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/config/app_info.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/intro/presentation/widgets/intro_common.dart';
import 'package:aura/features/payments/domain/payments.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/profile/presentation/widgets/delete_account_tile.dart';
import 'package:aura/shared/utils/external_link.dart';
import 'package:aura/shared/widgets/app_logo.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Moldura comum das telas de bloqueio (paywall, conexão, atualização,
/// verificação): fundo do tema, partículas discretas, logo, Aurudo e uma
/// coluna centralizada (nunca esticada no desktop).
class PaywallFrame extends StatelessWidget {
  const PaywallFrame({
    required this.children,
    this.pose = AurudoPose.neutral,
    this.particles = true,
    this.aurudoSize = 150,
    this.showMark = true,
    this.showMascot = true,
    this.particleStyle = AuraParticlesStyle.ambient,
    this.particleCount = 6,
    this.bottom,
    this.onClose,
    super.key,
  });

  /// The "A" monogram above the mascot. The purchase screens leave it out:
  /// Aurudo already carries the brand there.
  final bool showMark;

  /// Telas de escolha de plano dispensam o mascote: o espaço vai para os planos.
  final bool showMascot;

  /// Brilhos de fundo (a tela de sucesso usa o estilo burst, mais cheio).
  final AuraParticlesStyle particleStyle;
  final int particleCount;

  /// Pinned under the scrolling content, above the safe area (the main
  /// call to action of a success screen).
  final Widget? bottom;

  /// Só quando a tela é uma visita voluntária (acesso já liberado, ex.: teste
  /// querendo assinar antes do fim). Em bloqueio é nulo: não há como voltar.
  final VoidCallback? onClose;

  final List<Widget> children;
  final AurudoPose pose;
  final bool particles;
  final double aurudoSize;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // O bloqueio não é uma tela "voltável": voltar nunca reabre o estudo.
      canPop: onClose != null,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            if (particles)
              Positioned.fill(
                child: IgnorePointer(
                  child: AuraParticles(style: particleStyle, count: particleCount),
                ),
              ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                          vertical: AppSpacing.xxl,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showMark) ...[
                                const Center(child: AppLogo.mark(size: 44)),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              if (showMascot) ...[
                              Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    // The halo may exceed the mascot's box
                                    // without taking layout space.
                                    Positioned.fill(
                                      child: OverflowBox(
                                        maxWidth: aurudoSize * 1.7,
                                        maxHeight: aurudoSize * 1.7,
                                        child: IntroGlow(
                                          size: aurudoSize * 1.7,
                                          opacity: 0.20,
                                        ),
                                      ),
                                    ),
                                    AurudoIllustration(
                                      pose: pose,
                                      size: aurudoSize,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              ] else
                                const SizedBox(height: AppSpacing.lg),
                              ...children,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (bottom != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal,
                        AppSpacing.sm,
                        AppSpacing.pageHorizontal,
                        AppSpacing.xl,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: bottom,
                      ),
                    ),
                ],
              ),
            ),
            // Por último no Stack: acima do conteúdo rolável, senão ele engole o toque do X.
            if (onClose != null)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PaywallHeading extends StatelessWidget {
  const PaywallHeading({required this.title, required this.body, super.key});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, height: 1.4, color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

/// "Restam 2 dias e 5 h" / "Restam 3 h 20 min" / "Restam 12 min".
String remainingLabel(PortalStrings t, Duration d) {
  if (d.isNegative || d == Duration.zero) return t('menos de 1 min', 'less than 1 min', 'menos de 1 min');
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  if (days > 0) return '$days d${hours > 0 ? ' $hours h' : ''}';
  if (hours > 0) return '$hours h${minutes > 0 ? ' $minutes min' : ''}';
  return '${d.inMinutes.clamp(1, 59)} min';
}

String providerName(PortalStrings t, PayProvider p) => switch (p) {
  PayProvider.apple => 'Apple',
  PayProvider.google => 'Google Play',
  PayProvider.mercadopago => t('Mercado Pago (Web)', 'Mercado Pago (Web)', 'Mercado Pago (Web)'),
};

/// Como gerenciar uma assinatura, respeitando a regra da plataforma atual:
/// loja nativa abre os ajustes da PRÓPRIA loja; assinatura de outro provedor
/// só ganha instruções (nunca um link para checkout externo no app móvel).
class ManageInfo {
  const ManageInfo(this.text, {this.url});
  final String text;
  final String? url;
}

ManageInfo manageFor(PortalStrings t, SubscriptionInfo sub, PayProvider here) {
  switch (sub.provider) {
    case PayProvider.apple:
      return here == PayProvider.apple
          ? ManageInfo(
              t('Gerencie ou cancele nos ajustes da Apple.', 'Manage or cancel in your Apple settings.',
                  'Gestiona o cancela en los ajustes de Apple.'),
              url: 'https://apps.apple.com/account/subscriptions',
            )
          : ManageInfo(t('Assinatura feita pela Apple: gerencie em Ajustes > ID Apple > Assinaturas, em um aparelho Apple.',
              'Subscribed through Apple: manage it in Settings > Apple ID > Subscriptions on an Apple device.',
              'Suscripción hecha con Apple: gestiónala en Ajustes > ID de Apple > Suscripciones en un dispositivo Apple.'));
    case PayProvider.google:
      return here == PayProvider.google || kIsWeb
          ? ManageInfo(
              t('Gerencie ou cancele no Google Play.', 'Manage or cancel in Google Play.',
                  'Gestiona o cancela en Google Play.'),
              url: 'https://play.google.com/store/account/subscriptions',
            )
          : ManageInfo(t('Assinatura feita pelo Google Play: gerencie em uma conta Google, no Google Play.',
              'Subscribed through Google Play: manage it with your Google account in Google Play.',
              'Suscripción hecha con Google Play: gestiónala con tu cuenta de Google en Google Play.'));
    case PayProvider.mercadopago:
      return ManageInfo(here == PayProvider.mercadopago
          ? t('Gerencie nesta tela.', 'Manage it on this screen.', 'Gestiónala en esta pantalla.')
          : t('Assinatura feita pela Web: gerencie em aprovaura.lucksrei.com, na sua conta.',
              'Subscribed on the Web: manage it at aprovaura.lucksrei.com with your account.',
              'Suscripción hecha en la Web: gestiónala en aprovaura.lucksrei.com con tu cuenta.'));
  }
}

/// Operações essenciais da conta que o bloqueio NUNCA tira: termos,
/// privacidade, excluir conta, sair e trocar de conta.
class AccountFooter extends StatefulWidget {
  const AccountFooter({this.showDelete = true, this.showSignOut = true, super.key});
  final bool showDelete;
  final bool showSignOut;

  @override
  State<AccountFooter> createState() => _AccountFooterState();
}

class _AccountFooterState extends State<AccountFooter> {
  // Uma consulta só (os links legais não mudam durante a tela).
  late final _config = sl<AuthRepository>().publicConfig();
  bool get showDelete => widget.showDelete;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Builder(builder: (context) => _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final t = PortalStrings.watch(context);
    final colors = context.colors;
    Future<void> signOut() async {
      final loading = context.read<AppBlockingLoadingCubit>();
      final auth = context.read<AuthCubit>();
      try {
        await loading.run(auth.signOut, message: t('Saindo…', 'Signing out…', 'Saliendo…'));
      } catch (_) {}
      if (context.mounted) context.go('/login');
    }

    final style = TextButton.styleFrom(
      foregroundColor: colors.textSecondary,
      minimumSize: const Size(0, 44),
    );
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            TextButton(
              style: style,
              onPressed: () => openExternalLink(context, AppInfo.privacyPolicyUrl),
              child: Text(t('Política de privacidade', 'Privacy policy', 'Política de privacidad')),
            ),
            FutureBuilder(
              future: _config,
              builder: (context, snap) {
                final terms = snap.data?.legal.where((d) => d.kind == 'terms');
                if (terms == null || terms.isEmpty) return const SizedBox.shrink();
                return TextButton(
                  style: style,
                  onPressed: () => openExternalLink(context, terms.first.url),
                  child: Text(t('Termos de uso', 'Terms of use', 'Términos de uso')),
                );
              },
            ),
            if (widget.showSignOut)
              TextButton(
                style: style,
                onPressed: signOut,
                child: Text(t('Sair / trocar de conta', 'Sign out / switch account', 'Salir / cambiar de cuenta')),
              ),
          ],
        ),
        if (showDelete) const DeleteAccountTile(),
      ],
    );
  }
}

/// Cartão básico do paywall (superfície do tema, borda, raio do design system).
class PaywallCard extends StatelessWidget {
  const PaywallCard({required this.child, this.highlighted = false, this.onTap, super.key});
  final Widget child;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: highlighted ? Color.alphaBlend(c.primary.withValues(alpha: 0.08), c.surface) : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: highlighted ? c.primary : c.border, width: highlighted ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
      ),
    );
  }
}

/// Carregando o estado da assinatura: só um indicador, sem componentes parciais.
class PaywallLoading extends StatelessWidget {
  const PaywallLoading({this.onClose, super.key});
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: onClose != null,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Stack(
          children: [
            const Center(child: CircularProgressIndicator()),
            if (onClose != null)
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
