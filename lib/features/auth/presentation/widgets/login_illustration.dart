import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class LoginIllustration extends StatelessWidget {
  const LoginIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.32;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/login_illustration.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.05,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.background.withValues(alpha: 0),
                    context.colors.background,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
