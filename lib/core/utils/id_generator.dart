import 'dart:math';

/// A random RFC 4122 v4 UUID, generated locally with no server round trip.
/// Used to tag things like a quiz attempt before the award RPC is ever
/// called, so the backend can tell two calls for the same attempt apart
/// from two different attempts -- see award_quiz_xp() in
/// supabase/quiz_xp_ledger.sql.
String generateAttemptId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 10xx

  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
