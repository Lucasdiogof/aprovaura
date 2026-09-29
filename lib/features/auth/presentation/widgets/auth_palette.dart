import 'package:flutter/material.dart';

/// The colour tokens of the auth screens (login and sign-up), sampled from
/// the approved light and dark references. Both themes share one layout;
/// only these values change, picked from the app's current [Brightness] --
/// never from a flag passed in by the previous screen.
@immutable
class AuthPalette {
  const AuthPalette._({
    required this.background,
    required this.glowTop,
    required this.glowLeft,
    required this.glowRight,
    required this.glowLow,
    required this.decoLine,
    required this.hillLeft,
    required this.hillPink,
    required this.hillRight,
    required this.hillRimLeft,
    required this.hillRimRight,
    required this.sparkle,
    required this.cardFill,
    required this.sheetFill,
    required this.cardBorder,
    required this.cardShadow,
    required this.fieldFill,
    required this.fieldBorder,
    required this.label,
    required this.subtitle,
    required this.hint,
    required this.icon,
    required this.link,
    required this.promptText,
    required this.buttonGradient,
    required this.buttonShadow,
    required this.buttonRim,
    required this.backFill,
    required this.backBorder,
    required this.backIcon,
  });

  final Color background;

  /// Soft washes behind everything: top, left middle, right middle, and
  /// low on the right, above the hills.
  final Color glowTop;
  final Color glowLeft;
  final Color glowRight;
  final Color glowLow;

  /// The thin curves (top right, bottom).
  final Color decoLine;

  /// The hills along the bottom: the big one on the left, the small ridge
  /// behind it, the low ones on the right. Each fades into the page
  /// towards the bottom edge.
  final Color hillLeft;
  final Color hillPink;
  final Color hillRight;

  /// Light along the crests (dark only).
  final Color hillRimLeft;
  final Color hillRimRight;
  final Color sparkle;

  final Color cardFill;

  /// Sheets opened over the auth screens (password recovery).
  final Color sheetFill;
  final Color cardBorder;
  final Color cardShadow;
  final Color fieldFill;
  final Color fieldBorder;

  /// Field labels and typed text.
  final Color label;

  final Color subtitle;
  final Color hint;
  final Color icon;

  /// "Esqueci minha senha" and the action in the switch prompt.
  final Color link;
  final Color promptText;

  /// Top-left to bottom-right.
  final List<Color> buttonGradient;
  final Color buttonShadow;

  /// A hairline of light along the button's lower edge (dark only).
  final Color buttonRim;

  final Color backFill;
  final Color backBorder;
  final Color backIcon;

  static AuthPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static const light = AuthPalette._(
    background: Color(0xFFF8FAFE),
    glowTop: Color(0xFFDDF3FC),
    glowLeft: Color(0xFFDAD6FB),
    glowRight: Color(0xFFC8ECFC),
    glowLow: Color(0xFFE2F2FD),
    decoLine: Color(0xB08B63EE),
    hillLeft: Color(0xFFC4CFFB),
    hillPink: Color(0xFFD9C8F8),
    hillRight: Color(0xFFC6DCFC),
    hillRimLeft: Color(0x00FFFFFF),
    hillRimRight: Color(0x00FFFFFF),
    sparkle: Color(0xFF7B6CF2),
    cardFill: Color(0xE6FFFFFF),
    sheetFill: Color(0xFFFBFCFF),
    cardBorder: Color(0xFFE2DAF7),
    cardShadow: Color(0x1A7C5CFA),
    fieldFill: Color(0xFFF6F8FC),
    fieldBorder: Color(0xFFDCDEEA),
    label: Color(0xFF141A45),
    subtitle: Color(0xFF474B6A),
    hint: Color(0xFF8C8FA3),
    icon: Color(0xFF5B6078),
    link: Color(0xFF7C3AED),
    promptText: Color(0xFF3F4160),
    buttonGradient: [Color(0xFFB685F9), Color(0xFF9A6CFB), Color(0xFF6A5CFD)],
    buttonShadow: Color(0x407C5CFA),
    buttonRim: Color(0x00FFFFFF),
    backFill: Color(0x99F3F5FC),
    backBorder: Color(0xFFD6DBEA),
    backIcon: Color(0xFF191A43),
  );

  static const dark = AuthPalette._(
    background: Color(0xFF090E1F),
    glowTop: Color(0xFF102457),
    glowLeft: Color(0xFF22229A),
    glowRight: Color(0xFF063A6C),
    glowLow: Color(0xB02A2FA8),
    decoLine: Color(0xB06A55F2),
    hillLeft: Color(0xFF080C1D),
    hillPink: Color(0xFF151A55),
    hillRight: Color(0xFF0B1238),
    hillRimLeft: Color(0xCC6A4DFF),
    hillRimRight: Color(0xCC3F6BFF),
    sparkle: Color(0xFFBFD4FF),
    cardFill: Color(0xD9141C32),
    sheetFill: Color(0xFF111831),
    cardBorder: Color(0xFF4B4C9C),
    cardShadow: Color(0x665B4CF0),
    fieldFill: Color(0xFF12182B),
    fieldBorder: Color(0xFF333E5A),
    label: Color(0xFFF5F6FF),
    subtitle: Color(0xFFC4C8EC),
    hint: Color(0xFF7B84A6),
    icon: Color(0xFFB0BCDF),
    link: Color(0xFFB794F6),
    promptText: Color(0xFFD0D4F2),
    buttonGradient: [Color(0xFF9463F9), Color(0xFF7D56F5), Color(0xFF5641E8)],
    buttonShadow: Color(0x665B4CF0),
    buttonRim: Color(0x55D9CCFF),
    backFill: Color(0xFF12182B),
    backBorder: Color(0xFF2B3047),
    backIcon: Color(0xFFFFFFFF),
  );
}
