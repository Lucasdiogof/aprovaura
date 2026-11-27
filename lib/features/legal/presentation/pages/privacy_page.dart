import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/shared/utils/external_link.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

const _termsUrl = 'https://lucksrei.com/projects/aura/terms/';
const _privacyUrl = 'https://lucksrei.com/projects/aura/privacy/';

/// "Privacidade e termos": consulta dos documentos e aceite de novas versões.
/// Funciona sem Premium.
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});
  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final SupabaseClient _db = sl<SupabaseClient>();
  bool _loading = true, _busy = false, _failed = false;
  List<Map<String, dynamic>> _pending = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final st = await _db.rpc<dynamic>('get_legal_status').withRequestTimeout();
      if (!mounted) return;
      setState(() {
        _pending = (st as List? ?? const []).whereType<Map<String, dynamic>>().where((d) => d['accepted'] != true).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _failed = true;
        });
      }
    }
  }

  Future<void> _act(Future<dynamic> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
      await _load();
    } catch (_) {
      if (mounted) {
        final t = PortalStrings.read(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t('Não foi possível salvar. Tente novamente.', 'Could not save. Try again.',
                'No se pudo guardar. Inténtalo de nuevo.'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(children: [
        ModernAppBar(
          title: t('Privacidade e termos', 'Privacy and terms', 'Privacidad y términos'),
          showBackButton: true,
          onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView(padding: const EdgeInsets.all(AppSpacing.pageHorizontal), children: [
                      if (_failed)
                        ListTile(
                          leading: const Icon(Icons.wifi_off_rounded),
                          title: Text(t('Sem conexão. Toque para tentar de novo.', 'No connection. Tap to retry.',
                              'Sin conexión. Toca para reintentar.')),
                          onTap: _load,
                        ),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(t('Termos de Uso', 'Terms of Use', 'Términos de Uso')),
                        onTap: () => openExternalLink(context, _termsUrl),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(t('Política de Privacidade', 'Privacy Policy', 'Política de Privacidad')),
                        onTap: () => openExternalLink(context, _privacyUrl),
                      ),
                      for (final d in _pending)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(t('Nova versão: ${d['kind']} ${d['version']}', 'New version: ${d['kind']} ${d['version']}', 'Nueva versión: ${d['kind']} ${d['version']}')),
                            subtitle: Text(t('Leia o documento e aceite para continuar usando o app com a versão vigente.', 'Read the document and accept it to keep using the current version.', 'Lee el documento y acéptalo para seguir con la versión vigente.')),
                            trailing: TextButton(
                              onPressed: _busy ? null : () => _act(() => _db.rpc<dynamic>('record_legal_acceptance', params: {'p_kind': d['kind'], 'p_version': d['version'], 'p_platform': defaultTargetPlatform.name}).withRequestTimeout()),
                              child: Text(t('Aceitar', 'Accept', 'Aceptar')),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }
}
