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

/// Versão do texto de consentimento de compartilhamento (registrada a cada decisão).
const kSharingConsentVersion = '2026-12-01';
const _termsUrl = 'https://lucksrei.com/projects/aura/terms/';
const _privacyUrl = 'https://lucksrei.com/projects/aura/privacy/';

/// "Privacidade e termos": consulta de documentos, histórico de aceites, faixa
/// etária declarada e compartilhamento revogável de estatísticas com o professor.
/// Funciona sem Premium. Compartilhar só é permitido a quem declarou ser maior
/// de 18 anos (o servidor impõe); menores e faixa desconhecida nunca compartilham.
class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});
  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final SupabaseClient _db = sl<SupabaseClient>();
  bool _loading = true, _busy = false, _failed = false;
  String? _band;
  bool _shared = false;
  List<Map<String, dynamic>> _history = const [];
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
      final band = await _db.rpc<dynamic>('get_my_age_band').withRequestTimeout();
      final sh = await _db.rpc<dynamic>('get_study_sharing').withRequestTimeout();
      final hist = await _db.rpc<dynamic>('get_my_legal_history').withRequestTimeout();
      final st = await _db.rpc<dynamic>('get_legal_status').withRequestTimeout();
      if (!mounted) return;
      setState(() {
        _pending = (st as List? ?? const []).whereType<Map<String, dynamic>>().where((d) => d['accepted'] != true).toList();
        _band = band as String?;
        _shared = sh is Map && sh['granted'] == true;
        _history = (hist as List? ?? const []).whereType<Map<String, dynamic>>().toList();
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
    final bands = {
      'under_13': t('Menos de 13 anos', 'Under 13', 'Menos de 13 años'),
      '13_15': t('13 a 15 anos', '13 to 15', '13 a 15 años'),
      '16_17': t('16 a 17 anos', '16 to 17', '16 a 17 años'),
      'adult': t('18 anos ou mais', '18 or older', '18 años o más'),
    };
    final adult = _band == 'adult';
    final title = Theme.of(context).textTheme.titleMedium;
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
                      const Divider(),
                      Text(t('Faixa etária', 'Age range', 'Rango de edad'), style: title),
                      const SizedBox(height: 4),
                      Text(t(
                          'Guardamos só a faixa, nunca a data de nascimento. Ela define quais recursos de compartilhamento ficam disponíveis.',
                          'We only store the range, never your birth date. It decides which sharing features are available.',
                          'Solo guardamos el rango, nunca la fecha de nacimiento. Define qué funciones de compartir están disponibles.')),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(spacing: 8, children: [
                        for (final e in bands.entries)
                          ChoiceChip(
                            label: Text(e.value),
                            selected: _band == e.key,
                            onSelected: _busy
                                ? null
                                : (_) => _act(() => _db
                                    .rpc<dynamic>('set_my_age_band', params: {'p_band': e.key})
                                    .withRequestTimeout()),
                          ),
                      ]),
                      const Divider(height: 32),
                      Text(
                          t('Compartilhar estatísticas com meu professor', 'Share my statistics with my teacher',
                              'Compartir mis estadísticas con mi profesor'),
                          style: title),
                      const SizedBox(height: 4),
                      Text(t(
                          'O professor vinculado vê seu desempenho (acertos, tempo de estudo, evolução por matéria). Nunca vê suas redações, senhas, dados de pagamento ou respostas individuais. Você pode revogar quando quiser; isso não desfaz o vínculo com o professor.',
                          'Your linked teacher sees your performance (hits, study time, progress by subject). They never see your essays, passwords, payment data or individual answers. You can revoke any time; this does not remove the teacher link.',
                          'El profesor vinculado ve tu desempeño (aciertos, tiempo de estudio, evolución por materia). Nunca ve tus redacciones, contraseñas, datos de pago ni respuestas individuales. Puedes revocar cuando quieras; no deshace el vínculo con el profesor.')),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _shared,
                        onChanged: _busy || (!adult && !_shared)
                            ? null
                            : (v) => _act(() => _db.rpc<dynamic>('set_study_sharing',
                                params: {'p_granted': v, 'p_version': kSharingConsentVersion}).withRequestTimeout()),
                        title: Text(_shared
                            ? t('Compartilhando', 'Sharing', 'Compartiendo')
                            : t('Não compartilhando', 'Not sharing', 'No compartiendo')),
                        subtitle: adult
                            ? null
                            : Text(t('Disponível apenas para maiores de 18 anos.',
                                'Available only to users aged 18 or older.', 'Disponible solo para mayores de 18 años.')),
                      ),
                      const Divider(height: 32),
                      Text(t('Meus aceites', 'My acceptances', 'Mis aceptaciones'), style: title),
                      if (_history.isEmpty)
                        const Padding(padding: EdgeInsets.only(top: 8), child: Text('—'))
                      else
                        for (final h in _history)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text('${h['kind']} · ${h['version']}'),
                            subtitle: Text('${h['accepted_at']}'.split('T').first),
                          ),
                    ]),
                  ),
                ),
        ),
      ]),
    );
  }
}
