import 'dart:math';

/// Limits and stepping for the per-subject question counter on "Montar
/// simulado". The server (create_mock_exam in supabase/mock_exams.sql)
/// re-validates every count against real availability and the global cap;
/// this only decides what the + / - buttons do.
class MockExamQuantity {
  const MockExamQuantity._();

  /// Same cap create_mock_exam() enforces.
  static const maxTotalQuestions = 180;

  /// Preferred increment. Counts snap to multiples of this, except that the
  /// real ceiling is always reachable exactly (18 available -> 5, 10, 15, 18).
  static const step = 5;

  /// The most this subject can have: its real availability, but never
  /// enough to push the whole exam past [maxTotalQuestions].
  static int ceiling({
    required int available,
    required int otherSubjectsTotal,
  }) => max(0, min(available, maxTotalQuestions - otherSubjectsTotal));

  /// Next value for "+": the next multiple of [step], clamped to the
  /// ceiling -- so a remainder (18, or a combination with only 3) is still
  /// reachable. Returns [current] unchanged when already at the ceiling.
  static int increase({
    required int current,
    required int available,
    required int otherSubjectsTotal,
  }) {
    final top = ceiling(
      available: available,
      otherSubjectsTotal: otherSubjectsTotal,
    );
    if (current >= top) return current;
    final nextStep = (current ~/ step + 1) * step;
    return min(nextStep, top);
  }

  /// Next value for "-": back to the previous multiple of [step] (18 -> 15,
  /// 3 -> 0), otherwise one full step down. 0 means the subject is out.
  static int decrease(int current) {
    if (current <= 0) return 0;
    final remainder = current % step;
    return remainder == 0 ? current - step : current - remainder;
  }
}
