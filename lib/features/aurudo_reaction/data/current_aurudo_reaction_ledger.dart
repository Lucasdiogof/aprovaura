import 'package:aura/core/di/injection_container.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/data/aurudo_reaction_ledger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reaction ledger for whoever is signed in right now. Null if nobody
/// is -- shouldn't happen at a screen that requires auth to reach, but
/// callers treat that as "can't dedupe, so just don't dedupe" rather than
/// crashing on a null user.
///
/// Always call this fresh at the point of use, never cache the result
/// across a sign-out -- see [AurudoReactionLedger]'s own doc comment.
AurudoReactionLedger? currentAurudoReactionLedger() {
  final userId = sl<AuthRepository>().currentUser?.id;
  if (userId == null) return null;
  return AurudoReactionLedger(sl<SharedPreferences>(), userId: userId);
}
