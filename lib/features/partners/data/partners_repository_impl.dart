import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';
import 'package:aura/features/partners/domain/repositories/partners_repository.dart';

class PartnersRepositoryImpl implements PartnersRepository {
  PartnersRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<PartnerSummary>>> listActive() async {
    try {
      final rows = await _client
          .rpc<List<dynamic>>('list_active_partners')
          .withRequestTimeout();
      return Success([
        for (final row in rows)
          PartnerSummary(
            id: (row as Map)['partner_id'] as String,
            displayName: row['display_name'] as String,
          ),
      ]);
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  @override
  Future<Result<PartnerLink>> getMyLink() async {
    try {
      final raw = await _client
          .rpc<dynamic>('get_my_partner')
          .withRequestTimeout();
      final json = Map<String, dynamic>.from(raw as Map);
      final linkedAt = json['linked_at'];
      return Success(
        PartnerLink(
          partnerId: json['partner_id'] as String?,
          displayName: json['display_name'] as String?,
          linkedAt: linkedAt is String ? DateTime.tryParse(linkedAt) : null,
          everChose: json['ever_chose'] == true,
          hasPendingChange: json['pending_request'] != null,
        ),
      );
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  @override
  Future<Result<void>> link({String? partnerId, String? code}) async {
    try {
      await _client
          .rpc<void>(
            'link_partner',
            params: {'p_partner_id': ?partnerId, 'p_code': ?code},
          )
          .withRequestTimeout();
      return const Success(null);
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  @override
  Future<Result<void>> requestChange({
    required String partnerId,
    String? reason,
  }) async {
    try {
      await _client
          .rpc<dynamic>(
            'request_partner_change',
            params: {'p_new_partner': partnerId, 'p_reason': ?reason},
          )
          .withRequestTimeout();
      return const Success(null);
    } catch (error) {
      return Error(failureFromError(error));
    }
  }
}
