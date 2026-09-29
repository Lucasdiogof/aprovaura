import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/questions/presentation/quiz_result_tier.dart';

class MapQuizStrings {
  const MapQuizStrings(this.language);

  final AppLanguage language;

  String findPrompt(String regionName) => switch (language) {
    AppLanguage.portuguese => 'Encontre: $regionName',
    AppLanguage.english => 'Find: $regionName',
    AppLanguage.spanish => 'Encuentra: $regionName',
  };

  String get locateLabel => switch (language) {
    AppLanguage.portuguese => 'Localize no mapa',
    AppLanguage.english => 'Locate on the map',
    AppLanguage.spanish => 'Ubica en el mapa',
  };

  String get identifyFlagLabel => switch (language) {
    AppLanguage.portuguese => 'Identifique a bandeira',
    AppLanguage.english => 'Identify the flag',
    AppLanguage.spanish => 'Identifica la bandera',
  };

  String get flagPrompt => switch (language) {
    AppLanguage.portuguese => 'De qual país é essa bandeira?',
    AppLanguage.english => 'Which country does this flag belong to?',
    AppLanguage.spanish => '¿De qué país es esta bandera?',
  };

  String get revealedLabel => switch (language) {
    AppLanguage.portuguese => 'Era essa aqui',
    AppLanguage.english => 'It was this one',
    AppLanguage.spanish => 'Era esta',
  };

  String progressLabel(int correct, int total) => switch (language) {
    AppLanguage.portuguese => '$correct / $total',
    AppLanguage.english => '$correct / $total',
    AppLanguage.spanish => '$correct / $total',
  };

  String get finishedTitle => switch (language) {
    AppLanguage.portuguese => 'Você concluiu!',
    AppLanguage.english => 'You finished!',
    AppLanguage.spanish => '¡Terminaste!',
  };

  String finishedScore(int correct, int total) => switch (language) {
    AppLanguage.portuguese => 'Você acertou $correct de $total.',
    AppLanguage.english => 'You got $correct out of $total right.',
    AppLanguage.spanish => 'Acertaste $correct de $total.',
  };

  /// The headline above the result, by how the map actually went. Same
  /// voice as the quiz deck's: a map is one more activity, not its own
  /// little world, and "Perfeito!" should read the same in both.
  ///
  /// Never scolds. The lowest tier asks a question instead of naming a
  /// failure -- nobody needs to be told they do not know the map.
  String finishedHeadline(QuizResultTier tier) => switch (language) {
    AppLanguage.portuguese => switch (tier) {
      QuizResultTier.zero => 'Vamos continuar?',
      QuizResultTier.developing => 'Continue praticando',
      QuizResultTier.good => 'Mandou bem!',
      QuizResultTier.excellent => 'Perfeito!',
    },
    AppLanguage.english => switch (tier) {
      QuizResultTier.zero => 'Shall we keep going?',
      QuizResultTier.developing => 'Keep practicing',
      QuizResultTier.good => 'Nice work!',
      QuizResultTier.excellent => 'Perfect!',
    },
    AppLanguage.spanish => switch (tier) {
      QuizResultTier.zero => '¿Seguimos?',
      QuizResultTier.developing => 'Sigue practicando',
      QuizResultTier.good => '¡Bien hecho!',
      QuizResultTier.excellent => '¡Perfecto!',
    },
  };

  /// Map-specific on purpose: "revise o conteúdo" is advice for a quiz,
  /// not for someone learning where places are.
  String finishedSubtitle(QuizResultTier tier) => switch (language) {
    AppLanguage.portuguese => switch (tier) {
      QuizResultTier.zero =>
        'Esse mapa é difícil mesmo. Olhe com calma e tente de novo.',
      QuizResultTier.developing =>
        'Você já localizou algumas. Repetir o mapa fixa o resto.',
      QuizResultTier.good => 'Você conhece bem esse mapa, continue assim.',
      QuizResultTier.excellent =>
        'Você localizou tudo! Mapa concluído sem errar.',
    },
    AppLanguage.english => switch (tier) {
      QuizResultTier.zero =>
        'This map really is hard. Take your time and try again.',
      QuizResultTier.developing =>
        'You found some of them. Running the map again fixes the rest.',
      QuizResultTier.good => 'You know this map well, keep it up.',
      QuizResultTier.excellent =>
        'You found everything! Map completed without a miss.',
    },
    AppLanguage.spanish => switch (tier) {
      QuizResultTier.zero =>
        'Este mapa es difícil. Míralo con calma e intenta de nuevo.',
      QuizResultTier.developing =>
        'Ya ubicaste algunas. Repetir el mapa fija el resto.',
      QuizResultTier.good => 'Conoces bien este mapa, sigue así.',
      QuizResultTier.excellent => '¡Ubicaste todo! Mapa completado sin fallar.',
    },
  };

  /// An achievement earned on this same map takes over the headline --
  /// except perfect, which the resolver always keeps as the main reaction.
  String reactionHeadline(AurudoReactionType type, QuizResultTier tier) =>
      switch (type) {
        AurudoReactionType.levelUp => switch (language) {
          AppLanguage.portuguese => 'Subiu de nível!',
          AppLanguage.english => 'Level up!',
          AppLanguage.spanish => '¡Subiste de nivel!',
        },
        AurudoReactionType.streakMilestone => switch (language) {
          AppLanguage.portuguese => 'Sequência em dia!',
          AppLanguage.english => 'Streak going strong!',
          AppLanguage.spanish => '¡Racha en marcha!',
        },
        AurudoReactionType.dailyGoalComplete => switch (language) {
          AppLanguage.portuguese => 'Meta batida!',
          AppLanguage.english => 'Goal reached!',
          AppLanguage.spanish => '¡Meta alcanzada!',
        },
        _ => finishedHeadline(tier),
      };

  String levelUpBadge(int level) => switch (language) {
    AppLanguage.portuguese => 'Nível $level',
    AppLanguage.english => 'Level $level',
    AppLanguage.spanish => 'Nivel $level',
  };

  String streakMilestoneBadge(int days) => switch (language) {
    AppLanguage.portuguese => '$days dias seguidos',
    AppLanguage.english => '$days-day streak',
    AppLanguage.spanish => '$days días seguidos',
  };

  String get dailyGoalBadge => switch (language) {
    AppLanguage.portuguese => 'Meta batida',
    AppLanguage.english => 'Goal reached',
    AppLanguage.spanish => 'Meta alcanzada',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
    AppLanguage.spanish => 'Intentar de nuevo',
  };

  /// Brings the map back to the initial frame after the user zoomed or
  /// panned.
  String get showAllButton => switch (language) {
    AppLanguage.portuguese => 'Ver tudo',
    AppLanguage.english => 'Show all',
    AppLanguage.spanish => 'Ver todo',
  };

  String get zoomInTooltip => switch (language) {
    AppLanguage.portuguese => 'Aproximar',
    AppLanguage.english => 'Zoom in',
    AppLanguage.spanish => 'Acercar',
  };

  String get zoomOutTooltip => switch (language) {
    AppLanguage.portuguese => 'Afastar',
    AppLanguage.english => 'Zoom out',
    AppLanguage.spanish => 'Alejar',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
    AppLanguage.spanish => 'Volver',
  };
}
