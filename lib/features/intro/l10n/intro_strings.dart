import 'package:aura/core/l10n/app_language.dart';

/// Texts of the animated product presentation (intro). "Aura" and "Aurudo"
/// are the app's own terms and stay as they are in every language.
class IntroStrings {
  const IntroStrings(this.language);

  final AppLanguage language;

  String _t(String pt, String en, String es) => switch (language) {
    AppLanguage.portuguese => pt,
    AppLanguage.english => en,
    AppLanguage.spanish => es,
  };

  // --- chrome ---
  String get next => _t('Continuar', 'Continue', 'Continuar');
  String get back => _t('Voltar', 'Back', 'Atrás');
  String get skip => _t('Pular', 'Skip', 'Omitir');
  String get haveAccount =>
      _t('Já tenho conta', 'I already have an account', 'Ya tengo cuenta');
  String get createAccount =>
      _t('Criar minha conta', 'Create my account', 'Crear mi cuenta');
  String get signIn => _t('Entrar', 'Sign in', 'Entrar');
  String get languageTooltip =>
      _t('Idioma', 'Language', 'Idioma');
  String pageOf(int page, int total) => _t(
    'Tela $page de $total',
    'Page $page of $total',
    'Pantalla $page de $total',
  );

  // --- 1 ---
  String get t1Title => _t(
    'Bem-vindo ao AprovaAura',
    'Welcome to AprovaAura',
    'Bienvenido a AprovaAura',
  );
  String get t1Body => _t(
    'Estude, pratique e evolua na sua preparação para provas, com o Aurudo ao seu lado.',
    'Study, practice and grow in your exam prep, with Aurudo by your side.',
    'Estudia, practica y evoluciona en tu preparación para exámenes, con Aurudo a tu lado.',
  );

  // --- 2 ---
  String get t2Title =>
      _t('Pratique e evolua', 'Practice and improve', 'Practica y evoluciona');
  String get t2Body => _t(
    'Banco de questões por disciplina e trilha, exercícios por dificuldade e simulados do seu jeito.',
    'A question bank by subject and learning path, exercises by difficulty and mock exams your way.',
    'Banco de preguntas por materia y ruta, ejercicios por dificultad y simulacros a tu manera.',
  );
  String get t2Subjects => _t('Disciplinas', 'Subjects', 'Materias');
  String get t2Paths => _t('Trilhas', 'Learning paths', 'Rutas');
  String get t2Difficulty => _t('Dificuldade', 'Difficulty', 'Dificultad');
  String get t2Mock => _t('Simulados', 'Mock exams', 'Simulacros');
  String get sampleQuestion => _t(
    'Qual organela produz energia na célula?',
    'Which organelle produces energy in the cell?',
    '¿Qué orgánulo produce energía en la célula?',
  );
  String get sampleA => _t('Mitocôndria', 'Mitochondrion', 'Mitocondria');
  String get sampleB => _t('Ribossomo', 'Ribosome', 'Ribosoma');
  String get sampleC => _t('Lisossomo', 'Lysosome', 'Lisosoma');

  // --- 3 ---
  String get t3Title => _t(
    'Aprenda com seus erros',
    'Learn from your mistakes',
    'Aprende de tus errores',
  );
  String get t3Body => _t(
    'Revise o que errou, acompanhe suas estatísticas e mantenha a constância com metas diárias.',
    'Review what you missed, follow your stats and stay consistent with daily goals.',
    'Repasa lo que fallaste, sigue tus estadísticas y mantén la constancia con metas diarias.',
  );
  String get t3Review => _t('Revisão de erros', 'Mistake review', 'Repaso de errores');
  String get t3Stats => _t('Estatísticas', 'Stats', 'Estadísticas');
  String get t3Goal => _t('Meta diária', 'Daily goal', 'Meta diaria');
  String get t3Streak => _t('Constância', 'Consistency', 'Constancia');
  String get accuracy => _t('Acertos', 'Accuracy', 'Aciertos');
  String get goalDone => _t('Meta de hoje', "Today's goal", 'Meta de hoy');

  // --- 4 ---
  String get t4Title => _t(
    'Aprimore suas redações',
    'Improve your essays',
    'Mejora tus redacciones',
  );
  String get t4Body => _t(
    'Escolha um tema, escreva e receba uma correção assistida por IA, com base nas competências do ENEM e feedback para evoluir.',
    'Pick a topic, write, and get AI-assisted feedback based on the ENEM competencies, to help you improve.',
    'Elige un tema, escribe y recibe una corrección asistida por IA, basada en las competencias del ENEM, con feedback para mejorar.',
  );
  String get t4Note => _t(
    'Apoio ao estudo: não é nota oficial nem garantia de aprovação.',
    'A study aid: not an official score or a guarantee of approval.',
    'Apoyo al estudio: no es una nota oficial ni garantía de aprobación.',
  );
  String get essayTheme => _t('Tema de redação', 'Essay topic', 'Tema de redacción');
  String get competency => _t('Competência', 'Competency', 'Competencia');

  // --- 5 ---
  String get t5Title => _t('Farme Aura', 'Farm Aura', 'Farmea Aura');
  String get t5Body => _t(
    'Cada resposta rende Aura. Suba de nível, desbloqueie conquistas e mantenha sua sequência de estudos.',
    'Every answer earns Aura. Level up, unlock achievements and keep your study streak going.',
    'Cada respuesta da Aura. Sube de nivel, desbloquea logros y mantén tu racha de estudio.',
  );
  String get t5Gain => _t('Ganho de Aura', 'Aura gain', 'Ganancia de Aura');
  String get t5Level => _t('Nível', 'Level', 'Nivel');
  String get t5Achievements => _t('Conquistas', 'Achievements', 'Logros');
  String get t5Streak => _t('Sequência', 'Streak', 'Racha');
  String get t5Cta => _t(
    'Sua jornada começa agora.',
    'Your journey starts now.',
    'Tu viaje empieza ahora.',
  );
  String get startNow => _t('Começar agora', 'Start now', 'Empezar ahora');

  /// Only shown when the commercial model is active on the server; never
  /// claims the trial already started.
  String trialLine(int days) => _t(
    'Novas contas ganham $days dias de acesso grátis, a partir da confirmação do e-mail.',
    'New accounts get $days free days, starting once the email is confirmed.',
    'Las cuentas nuevas tienen $days días gratis, desde la confirmación del correo.',
  );
}
