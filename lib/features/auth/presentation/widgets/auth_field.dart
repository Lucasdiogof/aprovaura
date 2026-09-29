import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/shared/widgets/password_visibility_toggle.dart';

/// A labelled auth field: the label above ("E-mail", "Nome de usuário"),
/// then an outlined field of the layout's height with an icon
/// on the left and, for passwords, the show/hide eye on the right. An error
/// appears under the field and pushes what follows down; nothing overlaps.
class AuthField extends StatelessWidget {
  const AuthField({
    required this.layout,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.errorText,
    this.trailing,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.obscured,
    this.onToggleObscured,
    super.key,
  });

  final AuthLayout layout;
  final String label;
  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  /// A status on the right (the username check); ignored on password
  /// fields, which have the eye there.
  final Widget? trailing;
  final FocusNode? focusNode;

  /// Non-null makes it a password field with the eye toggle.
  final bool? obscured;
  final VoidCallback? onToggleObscured;

  static const _textHeight = 1.2;

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    final colors = context.colors;
    final obscured = this.obscured;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AuthLayout.fieldRadius),
          borderSide: BorderSide(color: color, width: width),
        );
    // Vertical padding that puts one line of text exactly in the middle of
    // a field of the layout's height (1px border on each side).
    final line = layout.fieldTextSize * _textHeight;
    final padV = (layout.fieldHeight - line) / 2;
    final textStyle = TextStyle(
      fontSize: layout.fieldTextSize,
      height: _textHeight,
      color: palette.label,
    );
    final iconBox = BoxConstraints.tightFor(
      width: AuthLayout.fieldIconBox,
      height: layout.fieldHeight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: layout.labelSize,
            height: _textHeight,
            fontWeight: FontWeight.w600,
            color: palette.label,
          ),
        ),
        SizedBox(height: layout.labelToField),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscured ?? false,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onSubmitted: onSubmitted,
          style: textStyle,
          cursorColor: colors.primary,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: palette.fieldFill,
            hintText: hintText,
            hintStyle: textStyle.copyWith(color: palette.hint),
            errorText: errorText,
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(vertical: padV),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AuthLayout.fieldIconInset),
              child: Icon(
                icon,
                size: AuthLayout.fieldIconSize,
                color: palette.icon,
              ),
            ),
            prefixIconConstraints: iconBox,
            suffixIcon: obscured == null
                ? trailing
                : PasswordVisibilityToggle(
                    obscured: obscured,
                    color: palette.icon,
                    onPressed: onToggleObscured!,
                  ),
            suffixIconConstraints: BoxConstraints.tightFor(
              width: AuthLayout.fieldSuffixBox,
              height: layout.fieldHeight,
            ),
            border: border(palette.fieldBorder),
            enabledBorder: border(palette.fieldBorder),
            focusedBorder: border(colors.primary, 1.4),
            errorBorder: border(colors.error),
            focusedErrorBorder: border(colors.error, 1.4),
          ),
        ),
      ],
    );
  }
}
