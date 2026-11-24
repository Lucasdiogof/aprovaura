import 'package:supabase_flutter/supabase_flutter.dart';

/// Falha de uma operação do portal. [code] é o SQLSTATE do servidor quando existe
/// (42501 = sem permissão, P00xx = regra de negócio).
class PortalException implements Exception {
  PortalException(this.code, this.message);
  final String? code;
  final String message;
  bool get forbidden => code == '42501';
  @override
  String toString() => message;
}

/// Único ponto de contato do portal com o servidor. Só chama RPCs `admin_*`
/// (cada uma valida o administrador no banco) e a Edge Function de
/// provisionamento. Nenhuma chave privilegiada existe no cliente.
class PortalApi {
  PortalApi(this._client, {this.onForbidden, this.onSessionLost});

  final SupabaseClient _client;
  final void Function()? onForbidden;
  final void Function()? onSessionLost;

  Future<T> _rpc<T>(String fn, [Map<String, dynamic>? params]) async {
    try {
      final r = await _client.rpc<dynamic>(fn, params: params);
      return r as T;
    } on PostgrestException catch (e) {
      if (e.code == '42501') onForbidden?.call();
      if (e.code == 'PGRST301' || e.message.contains('JWT')) onSessionLost?.call();
      throw PortalException(e.code, e.message);
    } on AuthException catch (e) {
      onSessionLost?.call();
      throw PortalException('auth', e.message);
    }
  }

  Future<Map<String, dynamic>> _map(String fn, [Map<String, dynamic>? p]) async =>
      Map<String, dynamic>.from(await _rpc<Map>(fn, p));

  static String _d(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Papéis lidos direto do servidor (nunca da autorização offline).
  Future<Map<String, dynamic>> me() => _map('get_my_access');

  Future<int> pendingRequests() async => (await _rpc<num>('admin_pending_change_count')).toInt();

  Future<Map<String, dynamic>> dashboard(DateTime from, DateTime to) =>
      _map('admin_dashboard', {'p_from': _d(from), 'p_to': _d(to)});

  Future<Map<String, dynamic>> users({
    String? search, String? access, String? partner, String? referral, String? email,
    DateTime? from, DateTime? to, String sort = 'created', String dir = 'desc',
    int limit = 25, int offset = 0,
  }) =>
      _map('admin_list_users', {
        'p_search': search, 'p_access': access, 'p_partner': partner, 'p_referral': referral,
        'p_email': email, 'p_from': from == null ? null : _d(from), 'p_to': to == null ? null : _d(to),
        'p_sort': sort, 'p_dir': dir, 'p_limit': limit, 'p_offset': offset,
      });

  Future<Map<String, dynamic>> user(String id) => _map('admin_get_user', {'p_user': id});

  Future<void> grantPremium(String user, {int? days, DateTime? endsAt, bool indefinite = false, String? note}) =>
      _rpc<dynamic>('admin_grant_premium', {
        'p_user': user, 'p_days': days, 'p_ends_at': endsAt?.toUtc().toIso8601String(),
        'p_indefinite': indefinite, 'p_note': note,
      });

  Future<void> revokeEntitlement(String id, {String? note}) =>
      _rpc<dynamic>('admin_revoke_entitlement', {'p_id': id, 'p_note': note});

  Future<void> setStudentPartner(String student, String? partner, {String? note}) =>
      _rpc<dynamic>('admin_set_student_partner', {'p_student': student, 'p_partner': partner, 'p_note': note});

  Future<Map<String, dynamic>> partners({String? search, String? status, int limit = 25, int offset = 0}) =>
      _map('admin_list_partners', {'p_search': search, 'p_status': status, 'p_limit': limit, 'p_offset': offset});

  Future<Map<String, dynamic>> partner(String id) => _map('admin_get_partner', {'p_partner': id});

  Future<void> updatePartner(String id, Map<String, dynamic> patch) =>
      _rpc<dynamic>('admin_update_partner', {'p_partner': id, 'p_patch': patch});

  Future<void> promotePartner(String user, String name,
          {String? code, int? bps, String? pixType, String? pixKey}) =>
      _rpc<dynamic>('admin_promote_partner', {
        'p_user': user, 'p_display_name': name, 'p_referral_code': code, 'p_commission_bps': bps,
        'p_pix_key_type': pixType, 'p_pix_key': pixKey,
      });

  /// Cria (ou reutiliza) a conta pelo e-mail e cria a parceria. Edge Function.
  Future<Map<String, dynamic>> provisionPartner({
    required String email, required String name, required String lang,
    String? code, int? bps, String? pixType, String? pixKey,
  }) async {
    try {
      final r = await _client.functions.invoke('admin-provision-partner', body: {
        'email': email, 'display_name': name, 'lang': lang, 'referral_code': code,
        'commission_bps': bps, 'pix_key_type': pixType, 'pix_key': pixKey,
      });
      return Map<String, dynamic>.from(r.data as Map);
    } on FunctionException catch (e) {
      final d = e.details;
      final err = d is Map ? '${d['error']}' : 'unavailable';
      if (e.status == 403) onForbidden?.call();
      throw PortalException(err, err);
    }
  }

  Future<Map<String, dynamic>> changeRequests({String? status, int limit = 25, int offset = 0}) =>
      _map('admin_list_change_requests', {'p_status': status, 'p_limit': limit, 'p_offset': offset});

  Future<Map<String, dynamic>> reviewRequest(String id, bool approve, {String? note}) =>
      _map('admin_review_partner_change', {'p_request': id, 'p_approve': approve, 'p_note': note});

  Future<Map<String, dynamic>> subscriptions({
    String? source, String? state, String? search, int limit = 25, int offset = 0,
  }) =>
      _map('admin_list_subscriptions', {
        'p_source': source, 'p_state': state, 'p_search': search, 'p_limit': limit, 'p_offset': offset,
      });

  Future<Map<String, dynamic>> config() => _map('admin_get_config');

  Future<void> updateConfig(Map<String, dynamic> patch) =>
      _rpc<dynamic>('admin_update_commercial_config', {'p_patch': patch});

  Future<Map<String, dynamic>> audit({
    String? actor, String? action, String? target, DateTime? from, DateTime? to,
    int limit = 25, int offset = 0,
  }) =>
      _map('admin_list_audit', {
        'p_actor': actor, 'p_action': action, 'p_target': target,
        'p_from': from == null ? null : _d(from), 'p_to': to == null ? null : _d(to),
        'p_limit': limit, 'p_offset': offset,
      });

  Future<List<String>> auditActions() async =>
      (await _rpc<List>('admin_audit_actions')).map((e) => '$e').toList();

  Future<Map<String, dynamic>> auditNeighbors(int id) => _map('admin_audit_neighbors', {'p_id': id});
}
