import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/map_quiz/domain/entities/flag_emoji.dart';
import 'package:aura/features/map_quiz/domain/entities/map_prompt_mode.dart';
import 'package:aura/features/map_quiz/l10n/map_quiz_strings.dart';

/// The question above the map, in one row plus a thin progress bar.
///
/// It used to be a padded card (~160 px on a phone) around the same three
/// things: what to find, how far along, and the progress bar. On a portrait
/// phone every pixel it gives back goes to the map -- which matters most
/// for world boards, framed by width.
class MapQuizHeader extends StatelessWidget {
  const MapQuizHeader({
    required this.strings,
    required this.promptMode,
    required this.targetId,
    required this.targetName,
    required this.revealed,
    required this.correctCount,
    required this.totalCount,
    super.key,
  });

  final MapQuizStrings strings;
  final MapPromptMode promptMode;
  final String targetId;
  final String targetName;
  final bool revealed;
  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFlag = promptMode == MapPromptMode.flag;
    final accent = revealed ? colors.warning : colors.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: isFlag
                      ? Text(
                          flagEmojiForCountryId(targetId) ?? '🏳️',
                          style: const TextStyle(fontSize: 20),
                        )
                      : Icon(Icons.gps_fixed_rounded, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        revealed
                            ? strings.revealedLabel
                            : isFlag
                            ? strings.identifyFlagLabel
                            : strings.locateLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: accent,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          isFlag ? strings.flagPrompt : targetName,
                          key: ValueKey(targetId),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    strings.progressLabel(correctCount, totalCount),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          LinearProgressIndicator(
            value: totalCount == 0 ? 0.0 : correctCount / totalCount,
            minHeight: 3,
            backgroundColor: colors.secondary,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ],
      ),
    );
  }
}
