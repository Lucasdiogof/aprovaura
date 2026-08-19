import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/streak/l10n/streak_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';

class StreakLostBottomSheet extends StatelessWidget {
  const StreakLostBottomSheet({required this.lostDays, super.key});

  static const _accentColor = Color(0xFFE8763D);

  final int lostDays;

  static Future<void> show(BuildContext context, {required int lostDays}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => StreakLostBottomSheet(lostDays: lostDays),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = StreakStrings(context.watch<LocaleCubit>().state);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accentColor.withValues(alpha: 0.16),
                  ),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: _accentColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                strings.lostTitle,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.lostDescription(lostDays),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              AppButton(
                label: strings.startAgainButton,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
