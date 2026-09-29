import 'package:flutter/foundation.dart';

/// The auth screens' geometry, measured on the approved references (a
/// 390pt-wide phone) and shared by the light and the dark theme. Login is
/// [regular]; sign-up has five fields instead of two, so the reference
/// tightens the same structure into [compact].
@immutable
class AuthLayout {
  const AuthLayout._({
    required this.markTop,
    required this.markToWordmark,
    required this.wordmarkToSubtitle,
    required this.subtitleToCard,
    required this.cardPaddingTop,
    required this.cardPaddingBottom,
    required this.labelSize,
    required this.labelToField,
    required this.fieldHeight,
    required this.fieldTextSize,
    required this.fieldToNextLabel,
    required this.lastFieldToButton,
    required this.buttonHeight,
    required this.buttonTextSize,
    required this.cardToPrompt,
  });

  /// From the bottom of the back-button row to the top of the symbol.
  final double markTop;
  final double markToWordmark;
  final double wordmarkToSubtitle;
  final double subtitleToCard;
  final double cardPaddingTop;
  final double cardPaddingBottom;
  final double labelSize;
  final double labelToField;
  final double fieldHeight;

  /// Typed text and placeholder.
  final double fieldTextSize;
  final double fieldToNextLabel;

  /// Sign-up only; login has "Esqueci minha senha" in between instead.
  final double lastFieldToButton;
  final double buttonHeight;
  final double buttonTextSize;
  final double cardToPrompt;

  // Shared by both screens.
  static const pagePadding = 16.0;
  static const cardInset = 4.0; // card edge 20pt from the screen edge
  static const maxContentWidth = 430.0;
  static const backButtonSize = 33.0;
  static const markWidth = 104.0;
  static const wordmarkWidth = 201.0;
  static const subtitleSize = 14.3;
  static const cardRadius = 16.0;
  static const cardPaddingX = 22.0;
  static const fieldRadius = 11.0;
  static const fieldIconBox = 40.0;

  /// Pushes the icon right inside its box, so it stays centred ~22pt
  /// from the field's edge while the text starts ~40pt in.
  static const fieldIconInset = 4.0;
  static const fieldIconSize = 19.5;

  /// The eye on password fields: centred ~22pt from the right edge.
  static const fieldSuffixBox = 44.0;
  static const buttonRadius = 12.0;
  static const promptSize = 12.75;

  // Login: "Esqueci minha senha" right under the password field.
  static const forgotSize = 11.5;
  static const forgotTapPadding = 6.0;
  static const fieldToForgot = 7.5;
  static const forgotToButton = 17.5;

  static const regular = AuthLayout._(
    markTop: 22,
    markToWordmark: 3,
    wordmarkToSubtitle: 3.9,
    subtitleToCard: 27.5,
    cardPaddingTop: 30,
    cardPaddingBottom: 26,
    labelSize: 13.5,
    labelToField: 7.9,
    fieldHeight: 46,
    fieldTextSize: 13,
    fieldToNextLabel: 19.7,
    lastFieldToButton: 0,
    buttonHeight: 49,
    buttonTextSize: 16,
    cardToPrompt: 15.3,
  );

  static const compact = AuthLayout._(
    markTop: 5,
    markToWordmark: 0.3,
    wordmarkToSubtitle: 0,
    subtitleToCard: 14.4,
    cardPaddingTop: 21.3,
    cardPaddingBottom: 21,
    labelSize: 12.6,
    labelToField: 7.4,
    fieldHeight: 41.6,
    fieldTextSize: 12.3,
    fieldToNextLabel: 16,
    lastFieldToButton: 22,
    buttonHeight: 44,
    buttonTextSize: 14.5,
    cardToPrompt: 0, // sign-up has no switch prompt
  );
}
