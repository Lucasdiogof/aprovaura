import 'package:equatable/equatable.dart';

/// Documento legal vigente publicado pelo servidor (política de
/// privacidade, termos). Só entra na lista o que já foi publicado.
class LegalDocument extends Equatable {
  const LegalDocument({
    required this.kind,
    required this.version,
    required this.url,
  });

  /// `privacy` ou `terms`.
  final String kind;
  final String version;
  final String url;

  @override
  List<Object?> get props => [kind, version, url];
}
