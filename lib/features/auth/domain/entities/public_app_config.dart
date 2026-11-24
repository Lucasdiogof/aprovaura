import 'package:equatable/equatable.dart';
import 'package:aura/features/auth/domain/entities/legal_document.dart';

/// What the app may know before login (get_public_app_config).
class PublicAppConfig extends Equatable {
  const PublicAppConfig({
    this.enforced = false,
    this.trialHours = 72,
    this.legal = const [],
  });

  /// The commercial model is active on the server.
  final bool enforced;
  final int trialHours;

  /// Current legal documents that must be accepted on sign-up.
  final List<LegalDocument> legal;

  /// Whole days of the experimental period, for display only.
  int get trialDays => (trialHours / 24).ceil();

  @override
  List<Object?> get props => [enforced, trialHours, legal];
}
