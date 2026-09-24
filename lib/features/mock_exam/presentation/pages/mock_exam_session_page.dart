import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Where an exam in progress is taken. TEMPORARY (FASE 3): only closes the
/// technical flow -- "the exam was created and is saved" -- so every entry
/// point (after creating, "Continuar simulado" on Home and in the active
/// sheet) already routes here. FASE 4/5 replaces this body with the real
/// exam-mode runner on top of MultipleChoiceView; callers don't change.
class MockExamSessionPage extends StatelessWidget {
  const MockExamSessionPage({required this.mockExamId, super.key});

  final String mockExamId;

  @override
  Widget build(BuildContext context) {
    final t = MockExamStrings(context.watch<LocaleCubit>().state);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: t.sessionTitle, showBackButton: true),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_turned_in_outlined,
                      size: 44,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.sessionPlaceholderTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.sessionPlaceholderDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
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
