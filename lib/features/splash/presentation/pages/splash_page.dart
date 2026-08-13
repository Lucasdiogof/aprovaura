import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:aura/features/splash/presentation/cubit/splash_state.dart';
import 'package:aura/shared/widgets/app_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(),
      child: BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) context.go('/login');
        },
        child: Scaffold(
          backgroundColor: context.colors.primary,
          body: Center(
            child: AppLogo(color: context.colors.onPrimary, fontSize: 48),
          ),
        ),
      ),
    );
  }
}
