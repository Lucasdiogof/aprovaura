import 'package:aura/features/aurudo_reaction/data/current_aurudo_reaction_ledger.dart';

/// Records that the correction of [submissionId] is being revealed, and
/// says whether it already had been.
///
/// Keyed by the submission alone on purpose: a submission has at most one
/// evaluation (`essay_evaluations.submission_id` is unique, and the server
/// refuses to mark an already-evaluated essay again). A retry after a
/// failed marking produces that submission's FIRST evaluation -- a failure
/// never stores one -- so it still gets its reveal, exactly once.
///
/// Only ever called with an evaluation in hand: a failed or pending
/// marking never reaches here, so it never spends the reveal.
bool markEssayCorrectionSeen(String submissionId) {
  final ledger = currentAurudoReactionLedger();
  if (ledger == null) return false;
  if (ledger.hasCelebratedEssayCorrection(submissionId)) return true;
  ledger.markEssayCorrectionCelebrated(submissionId);
  return false;
}
