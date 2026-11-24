import 'package:equatable/equatable.dart';

/// Decisão de acesso devolvida pelo servidor (get_my_access) ou reconstruída
/// de uma autorização offline assinada. A UI só LÊ isto; quem decide é o
/// servidor.
class AccessStatus extends Equatable {
  const AccessStatus({
    required this.enforced,
    required this.allowed,
    this.isAdmin = false,
    this.isPartner = false,
    this.sources = const [],
    this.accessUntil,
    this.indefinite = false,
    this.minVersion = const {},
    this.fromOfflineGrant = false,
    this.needsConnection = false,
    this.authorizationExpiresAt,
  });

  /// Modelo comercial desligado: todos liberados (estado de hoje).
  static const open = AccessStatus(enforced: false, allowed: true);

  /// O modelo está ligado, mas sem autorização offline válida: precisa
  /// conectar para o servidor confirmar (ou renovar) o acesso.
  static const connectionRequired = AccessStatus(
    enforced: true,
    allowed: false,
    needsConnection: true,
  );

  final bool enforced;
  final bool allowed;
  final bool isAdmin;
  final bool isPartner;

  /// Fontes ativas: admin, partner, trial, apple, google, web, courtesy, transition.
  final List<String> sources;
  final DateTime? accessUntil;
  final bool indefinite;

  /// Versão mínima por plataforma (android/ios/web). Só orienta "atualize o
  /// app"; a autorização real é do servidor.
  final Map<String, String?> minVersion;
  final bool fromOfflineGrant;
  final bool needsConnection;

  /// Só offline: até quando a autorização local vale (não é o fim do Premium).
  final DateTime? authorizationExpiresAt;

  bool get isBlocked => enforced && !allowed;
  bool get isStaff => isAdmin || isPartner;
  bool get isTrial => sources.contains('trial');

  /// Só o teste de 72h sustenta o acesso (sem assinatura, cortesia ou papel).
  bool get trialOnly =>
      isTrial &&
      !isStaff &&
      !sources.any((s) => const {'apple', 'google', 'web', 'courtesy', 'transition'}.contains(s));

  factory AccessStatus.fromJson(Map<String, dynamic> json) {
    final roles = json['roles'];
    final until = json['access_until'];
    final min = json['min_version'];
    final sources = <String>[];
    final rawSources = json['sources'];
    if (rawSources is List) {
      for (final s in rawSources) {
        final name = s is Map ? s['source'] : s;
        if (name is String) sources.add(name);
      }
    }
    return AccessStatus(
      enforced: json['enforced'] == true,
      allowed: json['allowed'] == true,
      isAdmin: roles is Map && roles['admin'] == true,
      isPartner: roles is Map && roles['partner'] == true,
      sources: sources,
      accessUntil: until is String ? DateTime.tryParse(until) : null,
      indefinite: json['indefinite'] == true,
      minVersion: min is Map
          ? {for (final e in min.entries) e.key as String: e.value as String?}
          : const {},
    );
  }

  @override
  List<Object?> get props => [
    enforced,
    allowed,
    isAdmin,
    isPartner,
    sources,
    accessUntil,
    indefinite,
    minVersion,
    fromOfflineGrant,
    needsConnection,
    authorizationExpiresAt,
  ];
}

/// Para onde o app deve estar agora, decidido num lugar só (roteador e telas
/// leem isto; ninguém confere assinatura por conta própria).
enum AccessGate {
  /// Sessão aberta, mas o servidor ainda não respondeu.
  resolving,
  open,
  paywall,
  connectionRequired,
  updateRequired,

  /// Uma nova versão de documento legal exige novo aceite (só quando o servidor
  /// confirma `requires_reaccept`; nunca por falha de rede).
  legalRequired,
}

/// Documento legal vigente que o usuário ainda não aceitou e cuja publicação
/// marcou como "exige novo aceite".
class PendingLegal extends Equatable {
  const PendingLegal({required this.kind, required this.version, this.url});
  final String kind;
  final String version;
  final String? url;

  @override
  List<Object?> get props => [kind, version, url];
}

/// Por que o paywall aparece (só escolhe o texto; nunca concede nada).
enum BlockReason { none, trialExpired, subscriptionExpired, existingUser }

class AccessContext {
  const AccessContext({this.reason = BlockReason.none, this.pendingPayment = false});
  final BlockReason reason;
  final bool pendingPayment;

  factory AccessContext.fromJson(Map<String, dynamic> j) => AccessContext(
    reason: switch (j['reason']) {
      'trial_expired' => BlockReason.trialExpired,
      'subscription_expired' => BlockReason.subscriptionExpired,
      'existing_user' => BlockReason.existingUser,
      _ => BlockReason.none,
    },
    pendingPayment: j['pending_payment'] == true,
  );
}

/// true se [current] ("1.0.4") é anterior a [minimum]; sem mínimo => false.
bool isVersionBelow(String current, String? minimum) {
  if (minimum == null || minimum.trim().isEmpty) return false;
  List<int> parse(String v) => [
    for (final part in v.split('+').first.split('.')) int.tryParse(part) ?? 0,
  ];
  final a = parse(current);
  final b = parse(minimum);
  for (var i = 0; i < 3; i++) {
    final x = i < a.length ? a[i] : 0;
    final y = i < b.length ? b[i] : 0;
    if (x != y) return x < y;
  }
  return false;
}
